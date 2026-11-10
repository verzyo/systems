{
  den.aspects.networkmanager = {
    nixos = {lib, ...}: {
      networking = {
        networkmanager = {
          enable = true;

          wifi.backend = "iwd";
          dns = "systemd-resolved";
        };

        wireless.iwd.settings.General = {
          AddressRandomization = "network";
          AddressRandomizationRange = "full";
        };

        dhcpcd.enable = false;
        modemmanager.enable = lib.mkOverride 999 false;
      };

      services.resolved.enable = true;
      systemd.services.NetworkManager-wait-online.enable = false;
    };

    persist.directories = [
      "/var/lib/NetworkManager"
      "/var/lib/iwd"
      "/etc/NetworkManager/system-connections"
    ];
  };
}
