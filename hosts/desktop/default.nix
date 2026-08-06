_: {
  imports = [./disks.nix];

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "desktop";

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

    boot.grub.enable = true;
    networking.networkmanager.enable = true;

    home-manager.enable = true;
    nix.enable = true;
  };

  hardware.facter.reportPath = ./hardware.json;
  system.stateVersion = "26.11";
}
