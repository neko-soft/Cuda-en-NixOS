# CUDA en NixOS

Nvidia tiene la mala fama de hacerle la vida imposible a usuarios de Linux producto de la naturaleza propietaria de sus códigos. Sin embargo, herramientas como CUDA son utilizadas por muchos para acelerar cálculos computacionales a través de GPU. Configurar y utilizar las capacidad de las tarjetas gráficas de Nvidia puede ser un tremendo dolor de cabeza para quienes trabajan con Linux, pero sobretodo, con una distribuición tan epecial como lo es NixOS, por lo que he decidido documentar y explicar a través de este repo el proceso para poder utilizar dichas herramientas en un contexto de programación de Python con Tensorflow y/o Torch.


## Configuración del sistema.

Primero que nada, es necesario configurar el sistema en general, obteniendo los drivers necesarios de Nvidia. Esta información se encuentra en la página de [Nvidia de la Wiki de NixOS](https://nixos.wiki/wiki/Nvidia). 

Para este caso, las configuraciones utilizadas se encuentran en [nvidia.nix](nvidia.nix). Normlamente se pueden copiar directamente, con la excepción de `prime`, que sólo aplica a sistemas con GPUs híbridas, como es el caso de la mayoría de las laptops con GPU integrada + GPU dedicada. Lo anterior también está explicado en la página de [Nvidia de la Wiki de NixOS](https://nixos.wiki/wiki/Nvidia). 

```nix
hardware.graphics.enable = true;
services.xserver.videoDrivers = ["nvidia"];

hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = false;
  powerManagement.finegrained = false;
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.latest;
  nvidiaPersistenced = true;


  # Sólo para GPUs híbridas
  # Tarjeta gráfica integrada + dedicada
  # Este es el caso de la mayoría de las laptops
  prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
  };
};
```

## Agregar los Caches de la Nix Community Cachix.

Si uno intenta instalar CUDA directamente con nixpkgs como:
```nix
  environment.systemPackages = [
    pkgs.cudaPackages.cudatoolkit
  ];
```
Por lo general CUDA se compilará localmente del sistema, lo cual puede tardar varias horas. Para evitar esto, se utilizan los Caches de la [Nix Community](https://app.cachix.org/cache/nix-community) y los [Cuda Maintainers de Cachix](https://app.cachix.org/cache/cuda-maintainers) , los cuales proveen con binarios listos para utilizar. 

Para utilizar Cachix, se deben agregar las siguientes líneas a nuestro `configuration.nix`:

```nix
nix.settings = {
  substituters = [
    "https://nix-community.cachix.org"
	  "https://cuda-maintainers.cachix.org"
  ];
  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];
};
```

Para que funcione, se debe reconstruir el sistema con `sudo nixos-rebuild switch`, y con esto deberíamos poder descargar directamente los binarios desde el cache de la Nix Community.

Si por alguna razón se llegasen a cambiar las Public Keys, se pueden obtener desde los siguientes links:
https://app.cachix.org/cache/nix-community
https://app.cachix.org/cache/cuda-maintainers

## Verificar qué versiones de Python y paquetes tienen binarios disponibles.

Si bien ahora se poseen los Caches de Cachix, no todas las versiones de Python y sus paquetes tienen binarios disponibles. Para verificar cuales si, debemos utilizar los siguientes comandos:


```
nix search nixpkgs tensorflowWithCuda
nix search nixpkgs torchWithCuda
```

Es MUY IMPORTANTE utilizar las versiones `WithCuda` de los paquetes a instalar, puesto las versiones normales, `tensorflow` y `torch` para este caso, no tienen la capacidad de aceleración por GPU, incluso si se instala `cudatoolkit` por separado.

Al utilizar los comandos mencionados anteriormente, se deberían obtener resultados como los mostrados a continuación:

```
$ nix search nixpkgs tensorflowWithCuda

* legacyPackages.x86_64-linux.python312Packages.tensorflowWithCuda (2.19.0)
  Computation using data flow graphs for scalable machine learning

* legacyPackages.x86_64-linux.python313Packages.tensorflowWithCuda (2.19.0)
  Computation using data flow graphs for scalable machine learning
``` 

```
$ nix search nixpkgs torchWithCuda
* legacyPackages.x86_64-linux.python312Packages.pytorchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration

* legacyPackages.x86_64-linux.python312Packages.torchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration

* legacyPackages.x86_64-linux.python313Packages.pytorchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration

* legacyPackages.x86_64-linux.python313Packages.torchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration
```

Las dos cosas que hay que prestar atención son:
1. La versión de Python
2. La versión del paquete de Python

Para conocer el primer punto, se debe observar la sección que dice `...python312Packages...` y `...python313Packages...`. Esto nos indica que existen binarios SÓLO para Python versiones 3.12 y 3.13, por lo que si se necesita otra versión de Python se deberá compilar localmente CUDA, o utilizar otras herramientas como `conda`.

En el segundo punto, la información relevante se encuentra entre () al final del nombre del paquete. `(2.19.0)` y `(2.5.1)` para `tensorflow` y `torch` respectivamente. Estos números corresponden a la versión de los paquetes y es importante verificar en que canal de Nix Packages están disponibles. Por ejemplo, si buscamos [tensoflowWithCuda en el canal estable](https://search.nixos.org/packages?channel=24.11&from=0&size=50&sort=relevance&type=packages&query=tensorflowWithCuda) (canal estable es 24.11 al momento de escribir esto), nos encontramos con que está la versión 2.13.0 para Python 3.11 y 3.13.

![Resultado de buscar tensorflowWithCuda en paquetes estables 24.11 de Nix Packages](imgs/tensorflowEstableCompleto.png)

![Versión de tensorflowWithCuda resaltado para versión estable 24.11 de Nix Packages](imgs/tensorflowEstable.png)






## Crear un flake o un shell.nix para nuestro proyecto.

Una de las grandes ventajas de Nix y NixOS frente a otras distros, es la posibilidad de crear shells aislados de forma nativa, es decir no necesitamos depender de `venv` o ambientes de conda para trabajar con Phython. Lo mismo aplica para otros lenguajes de programación. Sin embargo, esta ventaja se convierte rápidamente en una desventaja debido a que Nix y NixOS utilizan una forma bastante distinta de organizar archivos y librerías, por lo que no se pueden instalar paquetes como se haría normalmente.

Si se intenta instalar alguna librería de Python con `pip install`, lo más probable es que esta no funcione, por lo que se deben instalar mediante Nix Packages directamente, para esto se utiliza un `nix shell` o un `flake` como los mostrados a continuación:

- Nix Shell
```nix
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
```

- Flake
```nix
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
              # Instala paquetes de python.
              pandas numpy matplotlib seaborn scikit-learn openpyxl
              xlrd jupyterlab yfinance pytz tensorflowWithCuda 
              torchWithCuda #torchvision-bin torchaudio-bin # Usar torchvision y torchaudio genera conflictos con dependencias
            ]))
          ];
        shellHook = ''
          echo "Entorno de desarrollo activado para IPSA Prediction :D"
 
        '';

        
        };
      });

}
```





Así está bien, no es necesario poner , entre cada entrada.

2) Después, en el flake tienes que usar "tensorflowWithCuda", o "TorchWithCuda", porque si instalas sólo "tensorflow" o "Torch", sólo va a instalar la versión para CPU.

3) Verificar cuál versión de python hay que usar, ya que no todos los tensorflow o torch de todas las versiones de python tienen los binarios, esto se hace con:

nix search nixpkgs tensorflowWithCuda
nix search nixpkgs torchWithCuda

El resultado debería ser algo tipo: 

$ nix search nixpkgs tensorflowWithCuda
* legacyPackages.x86_64-linux.python312Packages.tensorflowWithCuda (2.19.0)
  Computation using data flow graphs for scalable machine learning

* legacyPackages.x86_64-linux.python313Packages.tensorflowWithCuda (2.19.0)
  Computation using data flow graphs for scalable machine learning

$ nix search nixpkgs torchWithCuda
* legacyPackages.x86_64-linux.python312Packages.pytorchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration

* legacyPackages.x86_64-linux.python312Packages.torchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration

* legacyPackages.x86_64-linux.python313Packages.pytorchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration

* legacyPackages.x86_64-linux.python313Packages.torchWithCuda (2.5.1)
  PyTorch: Tensors and Dynamic neural networks in Python with strong GPU acceleration

Ahí uno ve que para tensorflowWithCuda, sólo la versión de python 3.12 y 3.13 tienen binarios, lo mismo para torchWithCuda.

4) Finalmente, si las versiones de python con binarios no están en el nixpkgs estable, usar la versión unstable en el flake:

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

5) Configuración de NVIDIA en configuration.nix

Esto es lo mismo que sale por ahí en internet, así que es relativamente sensillo.:

hardware.graphics.enable = true;
services.xserver.videoDrivers = ["nvidia"];
hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
};