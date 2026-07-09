{
  inputs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.nix.enable {
    nix = {
      gc = {
        automatic = true;
        persistent = true;

        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nixpkgs-stable.flake = inputs.nixpkgs-stable;
      };

      settings = {
        experimental-features = ["flakes" "nix-command"];

        auto-optimise-store = true;
        use-xdg-base-directories = true;

        flake-registry = "";
      };

      channel.enable = false;
      nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    };

    programs = {
      git.enable = true;
      nix-ld.enable = true;
      command-not-found.enable = false;
    };

    nixpkgs.config.allowUnfree = true;
    environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  };

  options.modules.nix.enable = lib.mkEnableOption "nix module";
}
