{pkgs, ...}: {
  imports = [./disks.nix];

  networking.hostName = "laptop";

  services.upower.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

  fonts.packages = with pkgs; [
    material-symbols
    roboto-flex
  ];

  modules = {
    desktop = {
      niri.enable = true;
      fonts.enable = true;

      greetd = {
        enable = true;
        autoLoginUser = "verz";
      };
    };

    services = {
      searx.enable = true;

      fstrim.enable = true;
      ananicy.enable = true;

      kanata.enable = true;
    };

    users = {
      verz.enable = true;
      root.enable = true;
    };

    sops = {
      enable = true;
      secretsFile = ./secrets.json;
    };

    boot = {
      lanzaboote.enable = true;
      plymouth.enable = true;
      kernel.enable = true;
    };

    networking = {
      enable = true;
      networkmanager.enable = true;
    };

    memory.enable = true;
    perlless.enable = true;

    time.enable = true;
    home-manager.enable = true;
    nix.enable = true;
  };

  hardware.facter.reportPath = ./hardware.json;
  system.stateVersion = "26.11";
}
