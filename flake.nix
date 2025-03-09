{
  description = "l3ngen dotfiles";
  inputs = {
    # Nix package sources
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    # NUR (Nix User Repository)
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pre-commit hooks
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    # Neovim flake
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, nur, pre-commit-hooks, flake-utils, nvf, ... }:
    let
      # Define system architecture
      system = "x86_64-linux";
      
      # Generate package set with overlays
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            stable = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          })
        ];
      };
      
      lib = nixpkgs.lib;
      
      # Shared arguments to pass to modules
      specialArgs = {
        inherit inputs system;
      };
      
      # Define username
                        # username = "david"; # hardcoded for now, you can make this more dynamic later
      
      # Function to create a NixOS system configuration
      mkSystem = hostname: lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          # Pass user.nix as a module, not importing it
          ./user.nix
          ./nixos/configuration.nix

({ pkgs, lib, ... }: {
  # Don't redefine the option here, it's already in gpu.nix

  # Just set the value using system.activationScripts
  config = {
    # This script will run during system activation (after build)
    system.activationScripts.detectGpu = lib.stringAfter [ "users" ] ''
      if ${pkgs.pciutils}/bin/lspci | grep -qi "nvidia"; then
        echo "Detected NVIDIA GPU"
      elif ${pkgs.pciutils}/bin/lspci | grep -qi "amd"; then
        echo "Detected AMD GPU"
      else
        echo "No specific GPU detected"
      fi
    '';

    # Set the vendor based on build-time detection
    hardware.gpu.vendor = let
      # Try to detect using a derivation that runs at build time, not eval time
      detect = pkgs.runCommand "detect-gpu" {} ''
        if [ -e /sys/class/drm ] && ls -la /sys/class/drm/ | grep -q "nvidia"; then
          echo "nvidia" > $out
        elif [ -e /sys/class/drm ] && (ls -la /sys/class/drm/ | grep -q "amdgpu" || ls -la /sys/class/drm/ | grep -q "radeon"); then
          echo "amd" > $out
        else
          echo "unknown" > $out
        fi
      '';
    in
      # Safely try to read the file, with a fallback if it fails
      lib.findFirst (x: x != null) "unknown" [
        (lib.findFirst (x: x != null) null [
          (if builtins.pathExists detect then lib.removeSuffix "\n" (builtins.readFile detect) else null)
        ])
      ];
  };
})

          # Now your GPU module can safely use the hardware.gpu.vendor option
          ./nixos/modules/gpu.nix


        home-manager.nixosModules.home-manager
        {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
                                                        # users.${username} = import ./home/home.nix;
            };
            # Set the hostname in the configuration
            networking.hostName = hostname;
          }
          nur.modules.nixos.default
          nvf.nixosModules.default
        ];
      };
    in
    {
      # Define system configurations for multiple hosts
      nixosConfigurations = {
        # Default configuration for "nixos" hostname
        nixos = mkSystem "nixos";
      };

      # Define Neovim package
      packages.${system}.neovim =
        (nvf.lib.neovimConfiguration {
          pkgs = pkgsFor system;
        }).neovim;

      # Define development shells
      devShells = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = pkgsFor system; in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixpkgs-fmt
              nil
              git
              python3
              nodejs
              rustc
              cargo
            ];
          };
        }
      );

      # Pre-commit hooks
      checks = flake-utils.lib.eachDefaultSystem (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
          };
        };
      });

      # Formatter
      formatter = flake-utils.lib.eachDefaultSystem (system: (pkgsFor system).nixpkgs-fmt);
    };
}
