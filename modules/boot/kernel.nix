{
  den.aspects.kernel.nixos = {
    pkgs,
    lib,
    ...
  }: {
    boot.kernelPackages = lib.mkOverride 1001 pkgs.linuxPackages_latest;
  };
}
