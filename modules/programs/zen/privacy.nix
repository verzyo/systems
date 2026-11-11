{
  den.aspects.zen.homeManager.programs.zen-browser = {
    profiles.default.presets.betterfox.enable = true;

    policies = {
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };

      DisableFirefoxStudies = true;
    };
  };
}
