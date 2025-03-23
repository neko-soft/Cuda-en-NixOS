{ lib, config, pkgs, ... }:

{ 
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
}
