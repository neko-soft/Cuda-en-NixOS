{ pkgs ? import (fetchTarball "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz") {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [

    # Instala python 3.12
    python312
    (python312.withPackages (ps: with ps; [
      # Instala paquetes de python.
      pandas numpy matplotlib seaborn scikit-learn openpyxl
      xlrd jupyterlab yfinance pytz tensorflowWithCuda 
      torchWithCuda #torchvision-bin torchaudio-bin # Usar torchvision y torchaudio genera conflictos con dependencias
    ]))
  ];

  shellHook = ''
    echo "Entorno de Python activado."
  '';
}
