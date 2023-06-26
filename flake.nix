{
  description =
    "Common classes for infrastructure layers of PythonEDA projects";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a15";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        description =
          "Common classes for infrastructure layers of PythonEDA projects";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-infrastructure/base";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/devShells.nix;
        pythoneda-infrastructure-base-for = { version, pythoneda-base, python }:
          let
            pname = "pythoneda-infrastructure-base";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              dbus-next
              pythoneda-base
              grpcio
              requests
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ "pythonedainfrastructure" ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              pip install ${pythoneda-base}/dist/pythoneda_base-${pythoneda-base.version}-py${pythonMajorVersion}-none-any.whl
              rm -rf .env
            '';

            postInstall = ''
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
        pythoneda-infrastructure-base-0_0_1a12-for = { pythoneda-base, python }:
          pythoneda-infrastructure-base-for {
            version = "0.0.1a12";
            inherit pythoneda-base python;
          };
      in rec {
        packages = rec {
          pythoneda-infrastructure-base-0_0_1a12-python38 =
            pythoneda-infrastructure-base-0_0_1a12-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-infrastructure-base-0_0_1a12-python39 =
            pythoneda-infrastructure-base-0_0_1a12-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-infrastructure-base-0_0_1a12-python310 =
            pythoneda-infrastructure-base-0_0_1a12-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-infrastructure-base-latest-python38 =
            pythoneda-infrastructure-base-0_0_1a12-python38;
          pythoneda-infrastructure-base-latest-python39 =
            pythoneda-infrastructure-base-0_0_1a12-python39;
          pythoneda-infrastructure-base-latest-python310 =
            pythoneda-infrastructure-base-0_0_1a12-python310;
          pythoneda-infrastructure-base-latest =
            pythoneda-infrastructure-base-latest-python310;
          default = pythoneda-infrastructure-base-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-infrastructure-base-0_0_1a12-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-infrastructure-base-0_0_1a12-python38;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-infrastructure-base-0_0_1a12-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-infrastructure-base-0_0_1a12-python39;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-infrastructure-base-0_0_1a12-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-infrastructure-base-0_0_1a12-python310;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-infrastructure-base-latest-python38 =
            pythoneda-infrastructure-base-0_0_1a12-python38;
          pythoneda-infrastructure-base-latest-python39 =
            pythoneda-infrastructure-base-0_0_1a12-python39;
          pythoneda-infrastructure-base-latest-python310 =
            pythoneda-infrastructure-base-0_0_1a12-python310;
          pythoneda-infrastructure-base-latest =
            pythoneda-infrastructure-base-latest-python310;
          default = pythoneda-infrastructure-base-latest;

        };
      });
}
