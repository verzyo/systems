{inputs, ...}: {
  flake-file = {
    inputs.determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

      inputs.nix.inputs = {
        nixpkgs.autoFollow = false;

        git-hooks-nix.follows = "";
        nixpkgs-23-11.follows = "";
        nixpkgs-regression.follows = "";
      };
    };

    nixConfig = {
      extra-substituters = ["https://install.determinate.systems"];
      extra-trusted-public-keys = ["cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="];
    };
  };

  den.aspects.nix.nixos = {
    imports = [inputs.determinate.nixosModules.default];

    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;

      gc = {
        automatic = true;
        persistent = true;

        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      optimise = {
        automatic = true;
        persistent = true;

        dates = ["weekly"];
      };

      settings = {
        use-xdg-base-directories = true;
        flake-registry = "";
        download-buffer-size = 268435456; # 256 MiB
      };

      channel.enable = false;
    };

    systemd.services.nix-daemon.serviceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
    };

    programs = {
      git.enable = true;
      command-not-found.enable = false;
    };
  };
}
