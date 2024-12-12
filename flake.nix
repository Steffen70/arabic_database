{
  description = "A development environment for PowerShell development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        unstable = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell = unstable.mkShell {
          buildInputs = [
            unstable.powershell
            unstable.nixpkgs-fmt
          ];

          shellHook = ''
            export SHELL="${unstable.powershell}/share/powershell/pwsh"

            pwsh

            exit 0
          '';
        };
      }
    );
} 
