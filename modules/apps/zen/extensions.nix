{lib, ...}: {
  den.aspects.zen.homeManager.programs.zen-browser.policies.ExtensionSettings =
    lib.mapAttrs (_: slug: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
    }) {
      "uBlock0@raymondhill.net" = "ublock-origin";
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
      "addon@darkreader.org" = "darkreader";
    };
}
