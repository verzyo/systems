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
          src = pkgs.fetchFromGitHub {
            owner = "kaitranntt";
            repo = "CLIProxyAPIPlus";
            rev = "main";
            hash = "sha256-T4SmrOM98U4WoDM1U01OFEd9LvfVRf+dTa+Z+FQH2AM=";
          };

          vendorHash = "sha256-OwbE1gz2Kc/bbobk2sDeyWmdweGJvOrDJWVsszKxYrk=";
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

        oauth-model-alias = {
          antigravity = [
            {
              name = "gemini-3.1-flash-lite";
              alias = "claude-haiku-4-5-20251001";
            }
            {
              name = "gemini-3.8-flash-high";
              alias = "claude-sonnet-5";
            }
            {
              name = "claude-opus-4-6-thinking";
              alias = "claude-opus-5";
            }
            {
              name = "claude-opus-4-6-thinking";
              alias = "claude-fable-5";
            }
            {
              name = "gemini-3.8-flash-high";
              alias = "claude-3-7-sonnet-20250219";
            }
            {
              name = "gemini-3.8-flash-high";
              alias = "claude-3-5-sonnet-20241022";
            }
            {
              name = "gemini-3.1-flash-lite";
              alias = "claude-3-5-haiku-20241022";
            }
            {
              name = "claude-opus-4-6-thinking";
              alias = "claude-3-opus-20240229";
            }
          ];
        };

        oauth-excluded-models = {
          antigravity = [
            "gemini-3.1-flash-image"
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
        {
          disabled = false;
          type = "antigravity";
          project_id = "aicode-consumers";
          email = secret "oauth/antigravity/free5/email";
          refresh_token = secret "oauth/antigravity/free5/refresh_token";
        }
      ];
    };
  };

  options.modules.services.cliproxyapi.enable = lib.mkEnableOption "cliproxyapi module";
}
