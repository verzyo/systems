{pkgs, ...}: {
  imports = [./disks.nix];

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "desktop";

  modules = {
    desktop = {
      niri.enable = true;

      greetd = {
        enable = true;
        autoLoginUser = "verz";
      };
    };

    services.kanata.enable = true;

    users = {
      verz.enable = true;
      root.enable = true;
    };

    boot.grub.enable = true;
    networking.networkmanager.enable = true;

    home-manager.enable = true;
    nix.enable = true;
  };

  hardware.facter.reportPath = ./hardware.json;
  system.stateVersion = "26.11";

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for 32-bit games (like older Source engine titles)
  };

  # 2. Steam Configuration
  programs.steam = {
    enable = true;

    # Open ports for Steam Remote Play and Local Network Game Transfers
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Translate X11 input to uinput for seamless Steam Input controller support under Wayland
    extest.enable = true;

    # Wrapper for running Winetricks commands for Proton prefixes
    protontricks.enable = true;

    # Declaratively install custom Proton versions directly into Steam
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    # Packages available within Steam's FHS/pressure-vessel environment
    extraPackages = with pkgs; [
      gamescope
      gamemode
      mangohud
    ];

    # Standalone GameScope Wayland session for Steam Big Picture mode
    gamescopeSession = {
      enable = true;
      args = [
        "-W"
        "2560"
        "-H"
        "1440"
        "-r"
        "165"
        "--adaptive-sync"
        "--prefer-vk-device"
        "1002:7550"
      ];
    };
  };

  # 3. Gaming Performance & Overlays
  programs.gamemode = {
    enable = true; # Optimizes CPU scheduling automatically
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
    };
  };

  programs.gamescope = {
    enable = true; # Wayland micro-compositor for better frametimes/upscaling
    # Keep capSysNice disabled to prevent Bubblewrap capability crashes in Steam's Proton runtime
    capSysNice = false;
    # Vulkan WSI layer (32-bit & 64-bit) for latency reduction, direct swapchain pacing and VRR
    enableWsi = true;
    # Ensure Gamescope compositing targets the discrete RX 9070 XT rather than the integrated GPU
    args = [
      "--prefer-vk-device"
      "1002:7550"
    ];
  };

  # Kernel sysctl tunables for high-performance Linux gaming
  boot.kernel.sysctl = {
    # SteamOS/Valve standard: prevents mmap allocation exhaustion in memory-heavy Proton titles
    "vm.max_map_count" = 2147483642;
    # High file descriptor limit for esync/fsync
    "fs.file-max" = 2097152;
    # Eliminate severe micro-stutters from kernel split-lock throttling in Proton games
    "kernel.split_lock_mitigate" = 0;
  };

  # Allow user to leverage gamemode renicing
  users.users.verz.extraGroups = ["gamemode"];

  environment.systemPackages = with pkgs; [
    mangohud # Highly customizable FPS and performance overlay (provides mangoapp for gamescope)
    steam-run # Provides an FHS environment to easily run GOG/DRM-free games
  ];
}
