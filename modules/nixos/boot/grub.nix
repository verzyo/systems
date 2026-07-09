{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.boot.grub.enable {
    boot.loader = {
      timeout = 0;

      grub = {
        enable = true;
        useOSProber = true;

        timeoutStyle = "hidden";
        backgroundColor = "#000000";
        splashImage = null;

        extraInstallCommands = let
          extraEntries = ''
            menuentry "UEFI Firmware Settings" --class efi {
              fwsetup
            }

            menuentry "Reboot" --class restart {
              reboot
            }

            menuentry "Shutdown" --class shutdown {
              halt
            }
          '';
        in "echo '${extraEntries}' >> /boot/grub/grub.cfg";

        efiSupport = true;
        device = "nodev";
      };

      efi.canTouchEfiVariables = true;
    };
  };

  options.modules.boot.grub.enable = lib.mkEnableOption "grub module";
}
