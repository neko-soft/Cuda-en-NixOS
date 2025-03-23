{ pkgs ? import (fetchTarball "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz") {} }:


pkgs.mkShell {
  buildInputs = [
    (pkgs.python3.withPackages (ps: with ps; [
        pandas
        numpy
        matplotlib
        seaborn
        scikit-learn
        openpyxl
        xlrd
        jupyterlab
        yfinance
        pytz

        # Importante usar la versión 'WithCuda' de estos paquetes para tener aceleración por GPU.
        tensorflowWithCuda 
        torchWithCuda
    ]))
  ];

  shellHook = ''
    echo "Entorno de Python activado."
  '';
}
