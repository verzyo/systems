{config, ...}: {
  nixos.modules.base.imports = with config.nixos.modules; [nix];
  home.modules.base.imports = with config.home.modules; [nix home-manager];
}
