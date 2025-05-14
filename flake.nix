{
  description = "l3ngen dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nur.url = "github:nix-community/NUR";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, nixos-hardware, nur, pre-commit-hooks, nvf, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Create an overlay for bbot
      bbotOverlay = final: prev: {
        bbot = import ./pkgs/bbot.nix { pkgs = final; };
      };

      # Helper function to create pkgs with overlays
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
          bbotOverlay
        ];
      };

      # Common modules for both configurations
      commonModules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            bbotOverlay
          ];
          environment.systemPackages = [ pkgs.bbot ];
        })
      ];
    in
    {
      nixosConfigurations = {
        da-desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ [
            ./da-desktop/configuration.nix
            nvf.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.david = import ./da-desktop/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        da-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ [
            ./da-laptop/configuration.nix
            nvf.nixosModules.default
          ];
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = pkgsFor system;
      in
      {
        packages = {
          bbot = pkgs.bbot;
          neovim = (nvf.lib.neovimConfiguration { pkgs = pkgs; }).neovim;
        };

        apps.home-manager = {
          type = "app";
          program = "${home-manager.packages.${system}.default}/bin/home-manager";
        };

        devShells.default = pkgs.mkShell {
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

        checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
          };
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
