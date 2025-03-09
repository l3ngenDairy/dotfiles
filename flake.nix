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
      username = "david"; # hardcoded for now, you can make this more dynamic later
      
      # Function to create a NixOS system configuration
      mkSystem = hostname: lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          # Pass user.nix as a module, not importing it
          ./user.nix
          ./nixos/configuration.nix
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
