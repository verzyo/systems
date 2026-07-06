_: {
  imports = [./disks.nix];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
  };

  hardware.facter.reportPath = ./hardware.json;
  system.stateVersion = "26.11";
}
