{den, ...}: {
  den = {
    hosts.aarch64-linux.beri = {};

    aspects.beri = {
      includes = with den.aspects; [
        adguard-home
        tailscale

        raspberry-pi-5
      ];

      nixos = {
        hardware.enableRedistributableFirmware = true;

        networking.networkmanager.enable = true;

        services.openssh.enable = true;
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgCZN7PNO0l8JhDmqaorGdzKRjcKVbqEeka9lR06pqC"
        ];

        system.stateVersion = "26.11";
      };
    };
  };
}
