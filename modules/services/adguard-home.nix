{
  den.aspects.adguard-home.nixos = {
    services.adguardhome = {
      enable = true;
      mutableSettings = false;

      settings = {
        http.address = "0.0.0.0:3000";

        dns = {
          bind_hosts = ["0.0.0.0"];
          port = 53;

          upstream_dns = ["https://dns.quad9.net/dns-query"];
          bootstrap_dns = ["9.9.9.9" "149.112.112.112"];

          enable_dnssec = true;
          cache_optimistic = true;
        };

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
        };

        filters = [
          {
            id = 1;
            enabled = true;
            name = "AdGuard DNS filter";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          }
          {
            id = 2;
            enabled = true;
            name = "HaGeZi Multi PRO";
            url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
          }
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
}
