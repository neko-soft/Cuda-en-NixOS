{
  description = "Entorno de desarrollo modelo predicción IPSA";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system;
                                config.allowUnfree = true;
                              };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [

            # Instala python 3.12
            python312
            (python312.withPackages (ps: with ps; [
              # Paquetes normales de Python
              pandas numpy matplotlib seaborn scikit-learn openpyxl
              xlrd jupyterlab yfinance pytz

              # Paquetes con aceleración por GPU con CUDA
              tensorflowWithCuda 
              torchWithCuda #torchvision-bin torchaudio-bin # Usar torchvision y torchaudio genera conflictos con dependencias
            ]))
          ];
        shellHook = ''
          echo "Entorno de Python activado."
        '';

        
        };
      });

}