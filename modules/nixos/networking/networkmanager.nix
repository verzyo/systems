{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.networking.networkmanager.enable {
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
    };

    services.resolved.enable = true;

    systemd.services.NetworkManager-wait-online.enable = false;
    networking.dhcpcd.enable = false;

    preservation = lib.mkIf config.modules.preservation.enable {
      preserveAt."/${config.modules.preservation.preservedSubvolume}".directories = [
        "/var/lib/iwd"
        "/var/lib/NetworkManager"
        "/etc/NetworkManager/system-connections"
      ];
    };
  };

  options.modules.networking.networkmanager.enable = lib.mkEnableOption "networkmanager module";
}
