{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.zen.homeModules.twilight];

  config = lib.mkIf config.modules.programs.zen.enable {
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      package = inputs.zen.packages.${pkgs.stdenv.hostPlatform.system}.twilight;

      policies = {
        AutofillCreditCardEnabled = false;
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFormHistory = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };
        EncryptedMediaExtensions.Enabled = true; # DRM for streaming
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
      };

      profiles.default = {
        isDefault = true;

        presets.betterfox.enable = true;

        search = {
          force = true;
          default = "ddg";
        };

        settings = {
          # Privacy
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.enabled" = true;

          # HTTPS-only
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;

          # Disable telemetry
          "toolkit.telemetry.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;

          # Disable annoying features
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          # Force dark mode
          "ui.systemUsesDarkTheme" = 1;
          "zen.view.window.scheme" = 0;
        };
      };
    };
  };

  options.modules.programs.zen.enable = lib.mkEnableOption "zen browser module";
}
