{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.hermes-agent.homeManagerModules.default];

  config = lib.mkIf config.modules.services.hermes-agent.enable {
    services.hermes-agent = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;

      settings = let
        cliproxyapi = config.services.cliproxyapi.settings;
      in {
        model = {
          provider = "custom";
          base_url = "http://${cliproxyapi.host}:${builtins.toString cliproxyapi.port}/v1";
          default = "claude-sonnet-5";
        };
      };

      backend.mode = "dashboard";
      backend.port = 9119;
    };

    nix.settings = {
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };

  options.modules.services.hermes-agent.enable = lib.mkEnableOption "hermes agent module";
}
