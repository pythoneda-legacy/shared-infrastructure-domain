"""
pythonedainfrastructure/pythonedadbus/dbus_signal_emitter.py

This file defines the DbusSignalEmitter class.

Copyright (C) 2023-today rydnr's pythoneda-infrastructure/base

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""
from pythoneda.event import Event
from pythoneda.event_emitter import EventEmitter

import abc
import asyncio
from dbus_next.aio import MessageBus
from dbus_next import BusType, Message, MessageType

import logging
from typing import Dict

class DbusSignalEmitter(EventEmitter, abc.ABC):

    """
    A Port that emits events as d-bus signals.

    Class name: DbusSignalEmitter

    Responsibilities:
        - Connect to d-bus.
        - Translate domain events to d-bus signals.

    Collaborators:
        - PythonEDAApplication: Requests emitting events.
    """
    def __init__(self):
        """
        Creates a new DbusSignalEmitter instance.
        """
        super().__init__()

    def emitters(self) -> Dict:
        """
        Retrieves the configured event emitters.
        :return: A dictionary with the event class name as key, and a dictionary as value. Such dictionary must include the following entries:
          - "interface": the event interface,
          - "busType": the bus type,
          - "destination": the event destination,
          - "path": the path,
          - "interfaceName": the interface,
          - "signal": the signal name,
          - "transformer": a function capable of transforming the event information into a list of parameters.
        :rtype: Dict
        """
        return {}

    def fqdn_key(self, cls: type) -> str:
        """
        Retrieves the key used for given class.
        :param cls: The class.
        :type cls: Class
        :return: The key.
        :rtype: str
        """
        return f'{cls.__module__}.{cls.__name__}'

    async def emit(self, event: Event):
        """
        Emits given event as d-bus signal.
        :param event: The domain event to emit.
        :type event: pythoneda.event.Event
        """
        await super().emit(event)
        collaborators = self.emitters()

        if collaborators:
            emitter = collaborators.get(self.fqdn_key(event.__class__), None)
            if emitter:
                interfaceClass = emitter["interface"]
                interface = interfaceClass()
                bus_type = emitter["busType"]
                bus = await MessageBus(bus_type=bus_type).connect()
                bus.export(interfaceClass.path(), interface)
                await bus.send(
                    Message.new_signal(
                        emitter["path"],
                        self.fqdn_key(interfaceClass),
                        emitter["signal"],
                        emitter["signature"](event),
                        emitter["transformer"](event)))
                logging.getLogger(self.__class__.__name__).info(f'Sent signal {interfaceClass.__module__}.{interfaceClass.__name__} on path {emitter["path"]} to d-bus {bus_type}')
