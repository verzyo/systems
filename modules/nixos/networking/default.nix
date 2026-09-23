{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.networking.enable {
    boot = {
      kernelModules = [
        "tcp_bbr"
        "sch_cake"
      ];

      kernel.sysctl = {
        "net.core.default_qdisc" = "cake";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_slow_start_after_idle" = 0;
      };
    };
  };

  options.modules.networking.enable = lib.mkEnableOption "networking module";
}
