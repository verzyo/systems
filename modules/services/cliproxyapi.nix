{
  den.aspects.cliproxyapi = {
    nixos = {config, ...}: {
      environment.systemPackages = [config.services.cliproxyapi.package];
      services.cliproxyapi = {
        enable = true;

        settings.remote-management = {
          allow-remote = true;
          disable-control-panel = false;

          secret-key = "vibin";
        };
      };
    };

    persist.directories = ["/var/lib/cliproxyapi"];
  };
}
