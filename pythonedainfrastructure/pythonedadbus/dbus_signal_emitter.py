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

import asyncio
from dbus_next.aio import MessageBus
from dbus_next import BusType, Message, MessageType

from typing import Dict

class DbusSignalEmitter(EventEmitter):

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
          - "destination": the event destination,
          - "path": the path,
          - "interface": the interface,
          - "member": the signal name,
          - "transformer": a function capable of transforming the event into a string.
        :rtype: Dict
        """
        return {}

    async def emit(self, event: Event):
        """
        Emits given event as d-bus signal.
        :param event: The domain event to emit.
        :type event: Event from pythoneda.event
        """
        await super().emit(event)
        emitters = signal_emitters().items()

        if emitters:
            emitter = emitters.get(event.__class__, None)
            if emitter:
                message = Message(
                    destination = emitter["destination"],
                    path = emitter["path"],
                    interface = emitter["interface"],
                    member = emitter["signal"],
                    body = emitter["transformer"](event)
                )
                await bus.send(message)
