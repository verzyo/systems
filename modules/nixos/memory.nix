{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.memory.enable {
    zramSwap = {
      enable = true;
      algorithm = "lz4";

      memoryPercent = 100;
      priority = 100;
    };

    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_bytes" = 268435456;
    };
  };

  options.modules.memory.enable = lib.mkEnableOption "memory module";
}
