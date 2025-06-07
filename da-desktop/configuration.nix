{ config, pkgs, lib, ... }:
# ===================================================================
# NIXOS CONFIGURATION LEGEND
# ===================================================================
#
# This configuration is organized in the following order:
#
# 1.  SYSTEM BASICS          - Basic system identification and imports
# 2.  BOOT CONFIGURATION     - Boot loader, kernel packages, and parameters
# 3.  HARDWARE CONFIGURATION - CPU, GPU (NVIDIA), Bluetooth, firmware
# 4.  STORAGE & FILESYSTEMS  - Drive mounts, swap, filesystem settings
# 5.  CORE SERVICES & DRIVERS- Networking, sound (PipeWire), printing, display
# 6.  SYSTEM SETTINGS        - Time/locale, documentation, shell, environment
# 7.  BUILT-IN PROGRAMS      - Vim/Neovim, Fish shell, Firefox, KDE Connect
# 8.  VIRTUALIZATION         - Podman (Docker), QEMU/KVM, virt-manager
# 9.  GAMING                 - Steam, gamemode, transmission
# 10. PACKAGE CONFIGURATION  - nixpkgs settings, unfree packages
# 11. SYSTEM PACKAGES        - All installable packages (organized by category)
# 12. FONTS                  - Font packages
# 13. NIX CONFIGURATION      - Garbage collection, experimental features
#
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # ===================================================================
  # SYSTEM BASICS
  # ===================================================================

  system.stateVersion = "25.05";
  networking.hostName = "da-desktop";

  # ===================================================================
  # BOOT CONFIGURATION
  # ===================================================================

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "lockdown=confidentiality" ];
  boot.kernelModules = [ "uvcvideo" ];

  # ===================================================================
  # HARDWARE CONFIGURATION
  # ===================================================================

  # --- CPU ---
  hardware.cpu.amd.updateMicrocode = true;

  # --- Graphics ---
  hardware.graphics.enable = true;

  # --- NVIDIA ---
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.nvidia-container-toolkit.enable = true;

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        Class = "0x000540";  # This sets the device class to include keyboard functionality
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # --- Firmware ---
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;

  # ===================================================================
  # STORAGE & FILESYSTEMS
  # ===================================================================

  services.fstrim.enable = true;
  fileSystems = {
    "/media/drive-1" = {
      device = "/dev/disk/by-uuid/61d1bd2e-1784-4aea-a561-7198ae6b6829";
      fsType = "ext4";
      options = [ "defaults" "nofail" "users" "exec" ];
    };
    "/media/drive-2" = {
      device = "/dev/disk/by-uuid/c54e517e-44cc-4a7e-9230-0905134ee93f";
      fsType = "ext4";
      options = [ "defaults" "nofail" "users" "exec" ];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096; # Size in MB (4GB)
    }
  ];

  boot.kernel.sysctl = {
    "vm.overcommit_memory" = 1;
    "vm.max_map_count" = 1048576;
  };

  # ===================================================================
  # CORE SERVICES & DRIVERS
  # ===================================================================

  # --- Networking ---
  networking = {
    networkmanager.enable = true;
  };

  # --- Sound ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    audio.enable = true;
  };

  # --- Printing ---
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # --- Display Manager ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "david";
  
  # PCSC-Lite daemon, to access smart cards
  services.pcscd.enable = true;
        
  # ===================================================================
  # SYSTEM SETTINGS
  # ===================================================================

  # --- Time & Locale ---
  time.timeZone = "Pacific/Auckland";
  i18n.defaultLocale = "en_NZ.UTF-8";

  # --- Documentation ---
  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
  };
  documentation.man.generateCaches = false;

  # --- Shell ---
  users.defaultUserShell = pkgs.fish;

  # --- Groups ---
  users.groups.video = {};

  # --- Environment Variables ---
  environment.variables = {
    EDITOR = "nvim";
    RANGER_LOAD_DEFAULT_RC = "FALSE";
    XKB_DEFAULT_LAYOUT = "us";
    GSETTINGS_BACKEND = "keyfile";
    PIPEWIRE_LATENCY = "512/48000";  # Balanced latency setting
  };

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "{HOME}/.steam/root/compatibilitytools.d";
  };

  # --- Performance ---
  services.system76-scheduler.settings.cfsProfiles.enable = true;
  services.upower.enable = lib.mkForce false;

  # --- Plasma 6 Specific ---
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konqueror     # Heavy old browser
    khelpcenter   # Not needed usually
    plasma-sdk    # Developer tools, not needed for normal users
  ];

  # ===================================================================
  # BUILT-IN PROGRAMS & SERVICES
  # ===================================================================


  # --- Vim/Neovim ---
  programs.vim.enable = true;
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        languages = {
          enableTreesitter = true;
          nix.enable = true;
          python.enable = true;
          rust.enable = true;
        };
      };
    };
  };

  # --- Fish Shell ---
  programs.fish.interactiveShellInit = ''
    fastfetch
  ''; 

  # --- Firefox ---
  programs.firefox.enable = true;

  # --- KDE Connect ---
  programs.kdeconnect.enable = true;

  # ===================================================================
  # VIRTUALIZATION
  # ===================================================================

  # --- Podman ---
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Optional: enables `docker` CLI
  };

  # --- QEMU/KVM ---
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf.enable = true;       # UEFI boot support (for Windows, etc.)
        runAsRoot = true;         # Optional: can be omitted if not needed
      };
    };
    spiceUSBRedirection.enable = true;  # SPICE USB redirection
  };
  programs.virt-manager.enable = true;   # GUI for managing VMs

  # ===================================================================
  # GAMING
  # ===================================================================

  # --- Steam ---
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # --- Transmission ---
  services.transmission.settings = {
    download-dir = "${config.services.transmission.home}/Downloads";
  };

  # ===================================================================
  # PACKAGE CONFIGURATION
  # ===================================================================

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0" ];
  };

  # ===================================================================
  # SYSTEM PACKAGES
  # ===================================================================

# ===================================================================
# SYSTEM PACKAGES
# ===================================================================
# LEGEND:
# [CORE]      - Essential tools/utilities
# [VIRT]      - Virtualization
# [GAMING]    - Gaming & Launchers
# [AUDIO]     - Audio Tools
# [MONITOR]   - System Monitoring
# [RUST]      - Rust-Based Utilities
# [HARDWARE]  - Hardware Tools
# [EDITORS]   - Text/Code Editors
# [WEBCAM]    - Webcam Utilities
# [MEDIA]     - Media & Productivity
# [WINE]      - Windows Compatibility
# [APPS]      - General Applications
# [BROWSERS]  - Web Browsers
# [COMM]      - Communication
# [OFFICE]    - Office Tools
# [FILES]     - File Utilities
# [MEDIA-X]   - Image/Video Tools
# [NETWORK]   - Networking & Printing
# [DEV]       - Development Tools
# [SECURITY]  - Security / Pentesting
# [SDR]       - Software Defined Radio
# [XORG]      - X11 and GUI Tools
# ===================================================================

environment.systemPackages = with pkgs; [
  protonvpn-gui
  # [CORE]
  file                 # Identify file types
  curl                 # Command-line tool for data transfer
  wget                 # Download files from the web
  unzip                # Extract .zip files
  tree                 # Display directories as a tree
  bat                  # cat clone with syntax highlighting
  ripgrep              # Faster alternative to grep
  exiftool             # Read/write metadata in files
  sops
  # [VIRT]
  libvirt              # Manage virtual machines
  qemu                 # Emulator and virtualizer
  spice-vdagent        # Spice guest tools for clipboard/display
  spice-gtk            # GTK support for Spice clients
  virt-manager         # GUI for managing virtual machines
  looking-glass-client # Share VM screen via PCI passthrough
  quickemu
  quickgui


  # [GAMING]
  mangohud             # In-game performance overlay
  bottles              # Wine app manager
  heroic               # Epic Games launcher
  lutris               # Game manager for all platforms
  prismlauncher        # Custom Minecraft launcher
  protonup             # Install Proton-GE versions
  umu-launcher         # Launcher for games/emulators
  ryujinx              # Experimental Nintendo Switch Emulator written in C#


  # [AUDIO]
  alsa-utils           # ALSA sound utilities
  pavucontrol          # GUI for PulseAudio volume control

  # [MONITOR]
  nvtopPackages.nvidia # GPU usage monitor (NVIDIA)
  fastfetch            # System info summary tool
  glances              # Real-time system monitoring
  btop                 # Resource monitor with UI
  htop                 # Interactive process viewer

  # [RUST]
  fd                   # Fast file search (like `find`)
  fish                 # User-friendly shell (Rust-based)
  uutils-coreutils-noprefix # Coreutils rewrite in Rust
  gitui                # TUI for Git repositories
  dua                  # Disk usage analyzer
  hyperfine            # Command-line benchmark tool
  yazi                 # TUI file manager
  xh                   # Fast HTTP request tool (like curl)
  dust                 # Disk usage with intuitive UI
  nushell              # Modern shell with structured data
  ncspot               # Spotify client in terminal
  fselect              # File search with SQL-like queries
  rusty-man            # Man pages for Rust packages
  delta                # Git diff with syntax highlighting
  ripgrep-all          # ripgrep + search in PDFs, docs, etc.
  tokei                # Count lines of code by language
  wiki-tui             # Wikipedia reader in terminal

  # [HARDWARE]
  solaar               # Logitech device manager
  v4l-utils            # Video4Linux tools for webcams
  usbutils             # Tools to list USB devices
  pciutils             # Tools to inspect PCI devices
  vulkan-tools         # Vulkan diagnostics and info

  # [EDITORS]
  neovim               # Modern extensible Vim-based editor

  # [WEBCAM]
  cheese               # GNOME webcam viewer
  guvcview             # GTK webcam test app
  zoom-us

  # [MEDIA]
  transmission_4-gtk   # BitTorrent client (GTK)
  handbrake            # Video transcoder/converter
  kepubify             # Convert eBooks for Kobo
  calibre              # eBook library manager
                
  
  sniffnet             # Network packet monitor
  speedcrunch          # Scientific calculator

  # [WINE]
  wineWowPackages.stable # Run Windows apps
  winetricks           # Install Windows DLLs/fonts for Wine

  # [APPS]
  freecad              # 3D parametric modeling
  sqlite               # Lightweight SQL database
  wl-clipboard         # Wayland clipboard utilities
  cliphist             # Clipboard history manager
  grayjay              # Modern open-source YouTube client

  # [BROWSERS]
  firefox              # Mozilla Firefox browser

  # [COMM]
  discord              # Voice/text chat for communities

  # [OFFICE]
  anki                 # Flashcard-based study tool
  libreoffice-qt6-fresh # Office suite with Qt interface
  hunspell             # Spell checking engine
  hunspellDicts.en-au  # Australian English dictionary
  obsidian             # Markdown-based note-taking app

  # [FILES]
  p7zip                # 7z compression utility

  # [MEDIA-X]
  ffmpeg               # Audio/video conversion toolkit
  flameshot            # Screenshot capture tool

  # [NETWORK]
  tcpdump              # Command-line network sniffer
  cups                 # Printing system for Unix

  # [DEV]
  gdb                  # GNU debugger
  gef                  # GDB plugin for reverse engineering
  valgrind             # Memory debugging and profiling
  gcc                  # GNU C compiler
  clang                # LLVM C/C++ compiler
  git                  # Version control system
  python3              # Python language
  pipx                 # Install/run Python apps in isolation
  python312Packages.cli-helpers # CLI helpers for Python tools
  python312Packages.netifaces   # Network interface info
  python312Packages.pip         # Python package manager
  linux-manual         # Linux command reference
  man-pages            # Traditional Unix man pages
  man-pages-posix      # POSIX-specific man pages

  # [SECURITY]
  aircrack-ng          # Crack WiFi passwords
  ffuf                 # Fuzzer for web paths
  ghidra-bin           # NSA reverse engineering tool
  gobuster             # Directory brute-forcing
  metasploit           # Security testing framework
  netcat-openbsd       # Network debugging tool
  nmap                 # Network scanner
  ropgadget            # Gadget finder for ROP exploits
  sqlmap               # SQL injection testing
  thc-hydra            # Password brute-forcer
  social-engineer-toolkit # Phishing & SE attack toolset
  wireshark            # Network packet analyzer
  wordlists            # Common passwords for cracking
  hashcat              # Password hash cracker

  # [SDR]
  pkg-config           # Build helper for C/C++
  rtl-sdr              # RTL-based SDR driver
  rtl-sdr-librtlsdr    # Library for rtl-sdr
  sdrpp                # SDR# inspired SDR software

  # [XORG]
  arandr               # Simple GUI for screen layout
  autorandr            # Auto-adjust screen setup
  lxappearance         # GTK theme/appearance tool
  picom                # X compositor (for transparency, etc.)
  xorg.xdpyinfo        # Display server info
  xorg.xrandr          # Resize/rotate screen
  libsForQt5.qtstyleplugin-kvantum # Qt theme engine
  libsForQt5.qt5ct     # Configure Qt5 appearance

  # [OTHER]
  yubioath-flutter     # 2FA TOTP tool for Yubikeys (GUI)
];




  # ===================================================================
  # FONTS
  # ===================================================================

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    cascadia-code
    font-awesome
    powerline-fonts
    powerline-symbols
  ];

  # ===================================================================
  # NIX CONFIGURATION
  # ===================================================================

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
