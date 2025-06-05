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
    sops-nix.url = "github:Mic92/sops-nix";  
    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";

    # Pre-commit hooks
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # Neovim flake
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    nur,
    pre-commit-hooks,
    flake-utils,
    nvf,
    sops-nix,            
    ...
  }: let
    # Define system architecture
    system = "x86_64-linux";
    
    # Helper function to generate a package set with overlays
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
        nur.overlay
      ];
    }; 
secretsFile = ./secrets/secrets.yaml;
  ageKeyFile = "/home/david/.config/sops/age/keys.txt";


  in {
    nixosConfigurations = {
      # Desktop configuration
      da-desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          sops-nix.nixosModules.sops                                      
          ./da-desktop/configuration.nix
          ./user.nix
          nvf.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.david = import ./da-desktop/home.nix;

             sops.secrets.userPassword = {
        sopsFile = secretsFile;
        key = "user-password";
      };

      sops.age.keyFile = ageKeyFile; 


          }
        ];
      };
    };

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
