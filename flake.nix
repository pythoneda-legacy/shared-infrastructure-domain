{
  description =
    "Common classes for infrastructure layers of PythonEDA projects";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a12";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
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
        shared = import ./nix/devShell.nix;
        pythoneda-infrastructure-base-for = { version, pythoneda-base, python }:
          python.pkgs.buildPythonPackage rec {
            pname = "pythoneda-infrastructure-base";
            inherit version;
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-base
              grpcio
              requests
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ "pythonedainfrastructure" ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              pip install ${pythoneda-base}/dist/pythoneda_base-0.0.1a12-py3-none-any.whl
            '';

            postInstall = ''
              mkdir $out/dist
              cp dist/*.whl $out/dist
            '';

            meta = with pkgs.lib; {
              inherit description license homepage maintainers;
            };
          };
        pythoneda-infrastructure-base-0_0_1a7-for = { pythoneda-base, python }:
          pythoneda-infrastructure-base-for {
            version = "0.0.1a7";
            inherit pythoneda-base python;
          };
      in rec {
        packages = rec {
          pythoneda-infrastructure-base-0_0_1a7-python38 =
            pythoneda-infrastructure-base-0_0_1a7-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-infrastructure-base-0_0_1a7-python39 =
            pythoneda-infrastructure-base-0_0_1a7-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-infrastructure-base-0_0_1a7-python310 =
            pythoneda-infrastructure-base-0_0_1a7-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-infrastructure-base-latest-python38 =
            pythoneda-infrastructure-base-0_0_1a7-python38;
          pythoneda-infrastructure-base-latest-python39 =
            pythoneda-infrastructure-base-0_0_1a7-python39;
          pythoneda-infrastructure-base-latest-python310 =
            pythoneda-infrastructure-base-0_0_1a7-python310;
          pythoneda-infrastructure-base-latest =
            pythoneda-infrastructure-base-latest-python310;
          default = pythoneda-infrastructure-base-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-infrastructure-base-0_0_1a7-python38 = shared.devShell-for {
            package = packages.pythoneda-infrastructure-base-0_0_1a7-python38;
            python = pkgs.python38;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-infrastructure-base-0_0_1a7-python39 = shared.devShell-for {
            package = packages.pythoneda-infrastructure-base-0_0_1a7-python39;
            python = pkgs.python39;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-infrastructure-base-0_0_1a7-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-infrastructure-base-0_0_1a7-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-infrastructure-base-latest-python38 =
            pythoneda-infrastructure-base-0_0_1a7-python38;
          pythoneda-infrastructure-base-latest-python39 =
            pythoneda-infrastructure-base-0_0_1a7-python39;
          pythoneda-infrastructure-base-latest-python310 =
            pythoneda-infrastructure-base-0_0_1a7-python310;
          pythoneda-infrastructure-base-latest =
            pythoneda-infrastructure-base-latest-python310;
          default = pythoneda-infrastructure-base-latest;

        };
      });
}
