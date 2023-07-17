{
  description = "Shared kernel for infrastructure layers of PythonEDA projects";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-shared-pythoneda = {
      url = "github:pythoneda-shared/pythoneda/0.0.1a23";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        pname = "pythoneda-shared-infrastructure";
        description =
          "Shared kernel for infrastructure layers of PythonEDA projects";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-shared/infrastructure";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/shared.nix;
        pythonpackage = "pythonedainfrastructure";
        pythoneda-shared-infrastructure-for =
          { python, pythoneda-shared-pythoneda, version }:
          let
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
              pythoneda-shared-pythoneda
              grpcio
              requests
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ pythonpackage ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              echo "pythoneda-shared-pythoneda: ${pythoneda-shared-pythoneda}"
              pip install ${pythoneda-shared-pythoneda}/dist/pythoneda_shared_pythoneda-${pythoneda-shared-pythoneda.version}-py${pythonMajorVersion}-none-any.whl
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
        pythoneda-shared-infrastructure-0_0_1a14-for =
          { python, pythoneda-shared-pythoneda }:
          pythoneda-shared-infrastructure-for {
            version = "0.0.1a14";
            inherit python pythoneda-shared-pythoneda;
          };
      in rec {
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-shared-infrastructure-latest;
          pythoneda-shared-infrastructure-0_0_1a14-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-shared-infrastructure-0_0_1a14-python38;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python38;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-shared-infrastructure-0_0_1a14-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-shared-infrastructure-0_0_1a14-python39;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-shared-infrastructure-0_0_1a14-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-shared-infrastructure-0_0_1a14-python310;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-shared-infrastructure-0_0_1a14-python311 =
            shared.devShell-for {
              package =
                packages.pythoneda-shared-infrastructure-0_0_1a14-python311;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python311;
              python = pkgs.python311;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-shared-infrastructure-latest =
            pythoneda-shared-infrastructure-latest-python311;
          pythoneda-shared-infrastructure-latest-python38 =
            pythoneda-shared-infrastructure-0_0_1a14-python38;
          pythoneda-shared-infrastructure-latest-python39 =
            pythoneda-shared-infrastructure-0_0_1a14-python39;
          pythoneda-shared-infrastructure-latest-python310 =
            pythoneda-shared-infrastructure-0_0_1a14-python310;
          pythoneda-shared-infrastructure-latest-python311 =
            pythoneda-shared-infrastructure-0_0_1a14-python311;
        };
        packages = rec {
          default = pythoneda-shared-infrastructure-latest;
          pythoneda-shared-infrastructure-0_0_1a14-python38 =
            pythoneda-shared-infrastructure-0_0_1a14-for {
              python = pkgs.python38;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python38;
            };
          pythoneda-shared-infrastructure-0_0_1a14-python39 =
            pythoneda-shared-infrastructure-0_0_1a14-for {
              python = pkgs.python39;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python39;
            };
          pythoneda-shared-infrastructure-0_0_1a14-python310 =
            pythoneda-shared-infrastructure-0_0_1a14-for {
              python = pkgs.python310;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python310;
            };
          pythoneda-shared-infrastructure-0_0_1a14-python311 =
            pythoneda-shared-infrastructure-0_0_1a14-for {
              python = pkgs.python311;
              pythoneda-shared-pythoneda =
                pythoneda-shared-pythoneda.packages.${system}.pythoneda-shared-pythoneda-latest-python311;
            };
          pythoneda-shared-infrastructure-latest =
            pythoneda-shared-infrastructure-latest-python311;
          pythoneda-shared-infrastructure-latest-python38 =
            pythoneda-shared-infrastructure-0_0_1a14-python38;
          pythoneda-shared-infrastructure-latest-python39 =
            pythoneda-shared-infrastructure-0_0_1a14-python39;
          pythoneda-shared-infrastructure-latest-python310 =
            pythoneda-shared-infrastructure-0_0_1a14-python310;
          pythoneda-shared-infrastructure-latest-python311 =
            pythoneda-shared-infrastructure-0_0_1a14-python311;
        };
      });
}
