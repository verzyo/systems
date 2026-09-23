_: {
  imports = [./disks.nix];

  networking.hostName = "laptop";

  modules = {
    desktop = {
      niri.enable = true;

      greetd = {
        enable = true;
        autoLoginUser = "verz";
      };
    };

    services = {
      searx.enable = true;
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

    networking.networkmanager.enable = true;
    memory.enable = true;

    home-manager.enable = true;
    nix.enable = true;
  };

  hardware.facter.reportPath = ./hardware.json;
  system.stateVersion = "26.11";
}
