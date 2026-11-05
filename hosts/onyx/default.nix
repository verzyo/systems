{config, ...}: {
  nixos.configurations.onyx.module = {
    imports = with config.nixos.modules; [
      verz

      lanzaboote
    ];

    hardware.facter.reportPath = ./hardware.json;
    system.stateVersion = "26.11";
  };
}
