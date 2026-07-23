_: {
  imports = [./disks.nix];

  networking.hostName = "laptop";

  modules = {
    users.verz.enable = true;

    desktop = {
      niri.enable = true;

      greetd = {
        enable = true;
        autoLoginUser = "verz";
      };
    };

    boot.grub.enable = true;
    networking.networkmanager.enable = true;

    home-manager.enable = true;
    nix.enable = true;
  };

  hardware.facter.reportPath = ./hardware.json;
  system.stateVersion = "26.11";
}
