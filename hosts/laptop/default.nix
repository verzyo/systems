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

    services.kanata.enable = true;

    users = {
      verz.enable = true;
      root.enable = true;
    };

    sops = {
      enable = true;
      secretsFile = ./secrets.json;
    };

    boot.grub.enable = true;
    networking.networkmanager.enable = true;

    home-manager.enable = true;
    nix.enable = true;
  };

  hardware.facter.reportPath = ./hardware.json;
  system.stateVersion = "26.11";
}
