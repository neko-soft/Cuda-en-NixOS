{ config, pkgs, ... }:

{
	# Configuración básica para GPU Nvidia
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


	# Instalar el paquete de cachix
	environment.systemPackages = with pkgs; [
		cachix
 	 ];

	# Agregar los Caches de la Nix Community
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


	# Activar los flakes
	nix.settings.experimental-features = [ "nix-command" "flakes" ];


}
