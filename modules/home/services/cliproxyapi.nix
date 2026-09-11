{
  inputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  imports = [inputs.cliproxyapi.homeModules.cliproxyapi];

  config = lib.mkIf config.modules.services.cliproxyapi.enable {
    services.cliproxyapi = let
      secret = key: config.lib.cliproxyapi.injectSecret osConfig.sops.secrets.${key}.path;
    in {
      enable = true;
      package =
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cli-proxy-api.overrideAttrs
        (_oldAttrs: {
          src = inputs.cliproxyapi-plus;

          vendorHash = "sha256-HSdRlAdjEiwpn4/Xj8R5M6cyaCTyWiFuChMzm1hPIQk=";
        });

      managementPasswordFile = lib.mkIf osConfig.modules.sops.enable osConfig.sops.secrets."management_pass".path;

      plugins = [
        "antigravity-coding-filter"
        "antigravity-priority"
        "quota-activation"
        "privacyfilter"
        "cpa-apply-patch"
        "grok-manager"
      ];

      settings = {
        host = "localhost";
        port = 8317;
        auth-dir = "~/.cli-proxy-api";
        force-model-prefix = true;

        logging-to-file = true;

        # Resilience & Stream Keep-Alives
        streaming = {
          keepalive-seconds = 15;
          bootstrap-retries = 2;
        };

        # Quota Failover Behavior
        quota-exceeded = {
          switch-project = true;
          switch-preview-model = true;
          antigravity-credits = true;
        };

        # Session Affinity & Exhaustive Rotation
        routing = {
          strategy = "round-robin";
          session-affinity = true;
          session-affinity-ttl = "1h";
        };

        # Retries & Cooldown Mechanics
        request-retry = 5;
        max-retry-credentials = 0; # 0 = try all matching credentials before failing
        max-retry-interval = 20;
        save-cooldown-status = true;
        transient-error-cooldown-seconds = 45;

        # Hide models that were explicitly verified to fail with the current
        # credentials. Untested models remain visible for provider-specific
        # experimentation.
        oauth-excluded-models = {
          antigravity = [
            "gemini-3.1-flash-image"
          ];

          codex = [
            "gpt-image-1.5"
            "gpt-image-2"
          ];

          kiro = [
            "kiro-minimax-m2-1"
          ];

          qoder = [
            "qoder/qmodel_38max"
          ];

          xai = [
            "grok-imagine-image"
            "grok-imagine-image-quality"
            "grok-imagine-image-2.0"
            "grok-imagine-video"
            "grok-imagine-video-1.5"
            "grok-imagine-video-1.5-preview"
            "grok-3-mini-fast"
            "grok-3-mini"
            "grok-4.20-multi-agent-0309"
            "grok-4.20-0309-non-reasoning"
            "grok-4.20-0309-reasoning"
            "grok-4.3"
            "grok-build-0.1"
          ];

          kilo = [
            "nvidia/nemotron-3.5-content-safety:free"
            "thinkingmachines/inkling-small:free"
            "nvidia/nemotron-3-ultra-550b-a55b:free"
          ];
        };

        # Cross-provider capability aliases. Each provider contributes one
        # verified model to an alias; the native model names remain available.
        # The benchmark data is used for relative quality/speed only, not cost.
        oauth-model-alias = {
          antigravity = [
            {
              name = "claude-opus-4-6-thinking";
              alias = "architect";
              fork = true;
            }
            {
              name = "gemini-3.8-flash-high";
              alias = "artisan";
              fork = true;
            }
            {
              name = "gemini-3.1-flash-lite";
              alias = "runner";
              fork = true;
            }
          ];

          codex = [
            {
              name = "gpt-5.6-terra";
              alias = "architect";
              fork = true;
            }
            {
              name = "gpt-5.5";
              alias = "artisan";
              fork = true;
            }
            {
              name = "gpt-5.6-luna";
              alias = "runner";
              fork = true;
            }
          ];

          kiro = [
            {
              name = "claude-sonnet-4-5-20250929";
              alias = "architect";
              fork = true;
            }
            {
              name = "kiro-deepseek-3-2";
              alias = "artisan";
              fork = true;
            }
            {
              name = "claude-haiku-4-5-20251001";
              alias = "runner";
              fork = true;
            }
          ];

          xai = [
            {
              name = "grok-4.6";
              alias = "architect";
              fork = true;
            }
            {
              name = "grok-4.5";
              alias = "artisan";
              fork = true;
            }
            {
              name = "grok-composer-2.5-fast";
              alias = "runner";
              fork = true;
            }
          ];

          kilo = [
            {
              name = "nvidia/nemotron-3-super-120b-a12b:free";
              alias = "architect";
              fork = true;
            }
            {
              name = "cohere/north-mini-code:free";
              alias = "artisan";
              fork = true;
            }
            {
              name = "stepfun/step-3.7-flash:free";
              alias = "runner";
              fork = true;
            }
          ];
        };

        plugins = {
          enabled = true;

          configs = {
            "antigravity-coding-filter".enabled = true;
            "antigravity-priority".enabled = true;
            "cpa-apply-patch".enabled = true;
            "privacyfilter".enabled = true;
            "quota-activation".enabled = true;
            "grok-manager".enabled = true;
          };
        };

        api-keys = lib.optional osConfig.modules.sops.enable (secret "proxy_key");
        remote-management.disable-control-panel = false;
      };
      oauth = [
        {
          disabled = false;
          type = "antigravity";
          project_id = "aicode-consumers";
          email = secret "oauth/antigravity/paid1/email";
          refresh_token = secret "oauth/antigravity/paid1/refresh_token";
        }
        {
          disabled = false;
          type = "antigravity";
          project_id = "aicode-consumers";
          email = secret "oauth/antigravity/free1/email";
          refresh_token = secret "oauth/antigravity/free1/refresh_token";
        }
        {
          disabled = false;
          type = "antigravity";
          project_id = "aicode-consumers";
          email = secret "oauth/antigravity/free2/email";
          refresh_token = secret "oauth/antigravity/free2/refresh_token";
        }
        {
          disabled = false;
          type = "antigravity";
          project_id = "aicode-consumers";
          email = secret "oauth/antigravity/free3/email";
          refresh_token = secret "oauth/antigravity/free3/refresh_token";
        }
        {
          disabled = false;
          type = "antigravity";
          project_id = "aicode-consumers";
          email = secret "oauth/antigravity/free4/email";
          refresh_token = secret "oauth/antigravity/free4/refresh_token";
        }
      ];
    };
  };

  options.modules.services.cliproxyapi.enable = lib.mkEnableOption "cliproxyapi module";
}
