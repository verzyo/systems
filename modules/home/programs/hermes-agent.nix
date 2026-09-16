{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.hermes-agent.enable {
    home.packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
      pkgs.ripgrep
      pkgs.nixd
      pkgs.clang-tools
      pkgs.pyright
      pkgs.poppler-utils
    ];

    home.sessionVariables = {
      SEARXNG_URL = "http://127.0.0.1:8888";
    };

    nix.settings = {
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };

  options.modules.programs.hermes-agent.enable = lib.mkEnableOption "hermes agent module";
}
