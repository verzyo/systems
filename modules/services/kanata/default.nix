{
  den.aspects.kanata.nixos.services.kanata = {
    enable = true;

    keyboards.all = {
      extraDefCfg = "concurrent-tap-hold yes";
      config = builtins.readFile ./config.kbd;
    };
  };
}
