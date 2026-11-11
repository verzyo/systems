{
  den.aspects.kernel.nixos = {
    pkgs,
    lib,
    ...
  }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
