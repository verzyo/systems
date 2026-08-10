{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    apps.install = {
      type = "app";
      meta.description = "Interactive host installation script";

      program = lib.getExe (pkgs.writeShellApplication {
        name = "install";

        runtimeInputs = with pkgs; [
          jq
          gum
          git
          disko
          openssh

          # SOPS & secrets management
          sops
          age
          ssh-to-age
          rbw
          pinentry-tty
          yq-go

          # System utilities
          util-linux # lsblk, mountpoint
          iputils # ping
        ];

        text = builtins.readFile "${self}/scripts/install.sh";
      });
    };
  };
}
