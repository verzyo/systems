{
  inputs,
  lib,
  config,
  pkgs,
  self,
  ...
}: {
  config = lib.mkIf config.modules.nix.enable {
    nix = {
      package = pkgs.lix;

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

      extraOptions = lib.mkIf config.modules.sops.enable ''
        !include ${config.sops.templates."nix-access-tokens.conf".path}
      '';
    };

    sops = lib.mkIf config.modules.sops.enable {
      secrets."personal_access_token".sopsFile = "${self}/secrets/github.json";
      templates."nix-access-tokens.conf" = {
        mode = "0444";
        content = ''
          access-tokens = github.com=${config.sops.placeholder.personal_access_token}
        '';
      };
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
