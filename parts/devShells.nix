{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        ssh-to-age
        sops
        mcp-nixos
      ];

      # derive age identity from ssh key at runtime, if it exists
      shellHook = ''
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
          export SOPS_AGE_KEY=$(${lib.getExe pkgs.ssh-to-age} -private-key -i "$HOME/.ssh/id_ed25519")
        fi
      '';
    };
  };
}
