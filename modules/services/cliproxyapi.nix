{
  den.aspects.cliproxyapi = {
    nixos = {config, ...}: {
      services.cliproxyapi.enable = true;
      environment.systemPackages = [config.services.cliproxyapi.package];
    };

    persist.directories = ["/var/lib/cliproxyapi"];
  };
}
