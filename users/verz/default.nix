{config, ...}: {
  nixos.modules.verz = {
    imports = with config.nixos.modules; [home-manager];

    users.users.verz = {
      isNormalUser = true;
      uid = 1000;

      extraGroups = ["wheel"];
      initialPassword = "verz";
    };
  };
}
