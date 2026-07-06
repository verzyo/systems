{inputs, ...}: {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = {config, ...}: {
    pre-commit.settings.hooks = {
      treefmt = {
        enable = true;
        package = config.treefmt.build.wrapper;
      };

      check-merge-conflicts.enable = true;
      trim-trailing-whitespace.enable = true;
      end-of-file-fixer.enable = true;
    };
  };
}
