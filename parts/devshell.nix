{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShellNoCC {
      inputsFrom = [config.treefmt.build.devShell];
    };
  };
}
