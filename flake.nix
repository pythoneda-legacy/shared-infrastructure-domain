{
  description =
    "Common classes for infrastructure layers of PythonEDA projects";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda = {
      url = "github:rydnr/pythoneda/0.0.1a4";
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
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        description =
          "Common classes for infrastructure layers of PythonEDA projects";
        license = pkgs.lib.licenses.gpl3;
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-infrastructure-layer =
            pythonPackages.buildPythonPackage rec {
              pname = "pythoneda-infrastructure-layer";
              version = "0.0.1a1";
              projectDir = ./.;
              src = ./.;
              format = "pyproject";

              nativeBuildInputs = [ pkgs.poetry ];
              propagatedBuildInputs = with pythonPackages; [
                pythoneda.packages.${system}.pythoneda
                grpcio
                requests
              ];

              checkInputs = with pythonPackages; [ pytest ];

              pythonImportsCheck = [ ];

              meta = with pkgs.lib; {
                inherit description license homepage maintainers;
              };
            };
          default = packages.pythoneda-infrastructure-layer;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}
