{ pkgs, ... }: {



    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackaages = ["python-2.7.18.8" "electron-25.9.0" ]; 
    };
    programs.kdeconnect.enable = true; 
    environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia                # btop for nvidia

    grayjay
    fd                                  # is a simple, fast and user-friendly alternative to find           rust implementation 
    fish                                # fish shell rust implementation 
    uutils-coreutils-noprefix           # rust implementation of coreutils  
    gitui                               # fast git ui rust implementation 
    dua                                 # Tool to conveniently learn about the disk usage of directories
    hyperfine                           # benchmarking tool
    yazi                                # file manager rust
    evil-helix                          # batteries-included text editor with vim bindings          rust
    xh                                  # Friendly and fast tool for sending HTTP requests                 rust
    dust                                # de + rust = dust. Like du but more intuitive
    dua                                 # Tool to conveniently learn about the disk usage of directories
    nushell                             # Modern shell written in Rust
    ncspot                              # Spotify cli
    fselect                             # Find files with SQL-like queries
    rusty-man                           # Rust man pages
    delta                               # Syntax-highlighting pager for git
    ripgrep-all                         # Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz and more usage rga
    tokei                               # Program that allows you to count your code, quickly
    wiki-tui                            # Simple and easy to use Wikipedia Text User Interface
    
      # === MOUSE ===
    solaar                              # mouse viewer
    neovim
    vim
    handbrake            
    kepubify            
    calibre           
    ciscoPacketTracer8            
    looking-glass-client            
    usbutils
    pciutils            
    glances           
    sniffnet
    btop
    speedcrunch
                
                #broken  protonvpn-gui             
    wineWowPackages.stable
    winetricks            
    freecad 
    sqlite
    vulkan-tools
    wl-clipboard
    cliphist
       # === APPS ===

     # -- browsers --
    firefox
       # -- fun --
    discord
    # -- office --
    anki # flashcard app
    libreoffice-qt6-fresh               # office suite 
    hunspell                            # hunspell is libreoffice spellchecker
    hunspellDicts.en-au           
    obsidian                            # markdown notes
    # -- media --
    vlc
    # -- files --
    bat                                 # cat with syntax highlighting
    file                                # usage file <target> this will output the file type
    p7zip                               # 7zip but better
    ripgrep                             # better grep usage rg 
    tree                                # shows files in a tree
    unzip                               # unzips 
    # -- image --
    ffmpeg                              # used for media manipulatin
    flameshot                           # screen shots 
    # -- system --
    fastfetch                           # display system info updated version of neofetch
    htop                                # task managet
    # -- network --
    tcpdump                             # Network sniffer      
    cups                                # print service
    curl                                # used for get and post requests
    wget                                # used to get files from server
    # === DEVELOPMENT ===
    # -- debugging --
    gdb                                 # GNU Project debugger, allows you to see what is going on `inside’ another program while it executes 
    gef                                 # Modern experience for GDB with advanced debugging features for exploit developers & reverse engineers
    valgrind                            # Debugging and profiling tool suite
    
    # -- libraries --
    # -- c --
    gcc
    clang
    # -- tools --
    git
    exiftool
    # -- python --
    python3
    pipx
    python312Packages.cli-helpers
    python312Packages.netifaces
    python312Packages.pip
    # (python3.withPackages (ps: with ps; [ requests ]))
    # -- man pages --
    linux-manual
    man-pages
    man-pages-posix
    # -- hacking --
    aircrack-ng
    ffuf
    ghidra-bin
    gobuster
    metasploit
    netcat-openbsd
    nmap
    ropgadget
    sqlmap
    thc-hydra
    social-engineer-toolkit
    wireshark
    wordlists
    hashcat

    # -- sdr --
    pkg-config
    rtl-sdr
    rtl-sdr-librtlsdr
    sdrpp

    # === XORG ===
    # -- applications --
    # -- tools --
    xorg.xdpyinfo # info on xserver
    # -- display --
    arandr
    autorandr
    lxappearance
    picom
    xorg.xrandr

    # -- theme --
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];

  fonts.packages = with pkgs; [
    # jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    cascadia-code
    # twemoji-color-font
    font-awesome
    powerline-fonts
    powerline-symbols
    # (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })	
    ];
}


