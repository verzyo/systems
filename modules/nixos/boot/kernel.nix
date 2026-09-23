{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.chaotic.nixosModules.default];

  config = lib.mkIf config.modules.boot.kernel.enable {
    boot = {
      kernelPackages = pkgs.linuxPackages_cachyos;

      kernelModules = ["tcp_bbr"];

      kernelParams = [
        "preempt=full"
        "nowatchdog"
        "nmi_watchdog=0"
        "split_lock_mitigate=0"
        "skew_tick=1"
      ];
    };

    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    nix.settings = {
      substituters = ["https://nyx-cache.chaotic.cx/"];
      trusted-public-keys = ["nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="];
    };
  };

  options.modules.boot.kernel.enable = lib.mkEnableOption "kernel module";
}
