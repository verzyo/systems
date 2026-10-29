{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.ioscheduler.enable {
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
    '';
  };

  options.modules.ioscheduler.enable = lib.mkEnableOption "ioscheduler module";
}
