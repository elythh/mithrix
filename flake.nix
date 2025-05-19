{
  description = "NixOS and Home Manager Configuration Flake for my Hosts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    outputs = self;
    mkLib = pkgs: pkgs.lib.extend (final: prev: (import ./lib final pkgs) // home-manager.lib);
    packages = nixpkgs.legacyPackages;
    hmPackages = home-manager.inputs.nixpkgs.legacyPackages;

    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    mkSystem = {
      system ? "x86_64-linux",
      systemConfig,
      userConfigs ? null,
      lib ? mkLib packages.${system},
    }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs lib;
        };
        modules =
          [
            {nixpkgs.hostPlatform = system;}
            ./modules/nixos
            ./modules/shared
            ./hosts/shared/shared.nix
            ./hosts/shared/configuration.nix
            systemConfig
          ]
          ++ lib.lists.optionals (userConfigs != null) [
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [./modules/home-manager ./hosts/shared/home.nix];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs outputs lib;};
              home-manager.users = userConfigs;
            }
          ];
      };

    mkHome = {
      system ? "x86_64-linux",
      cfgPath,
      lib ? mkLib hmPackages.${system},
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = hmPackages.${system};
        extraSpecialArgs = {inherit inputs outputs lib;};
        modules = [
          ./modules/home-manager
          ./modules/shared
          ./hosts/shared/shared.nix
          ./hosts/shared/home.nix
          cfgPath
        ];
      };
  in {
    nixosConfigurations = {
      mithrix = mkSystem {systemConfig = ./hosts/mithrix/configuration.nix;};
    };

    homeConfigurations = {
      gwen = mkHome {cfgPath = ./hosts/mithrix/home.nix;};
    };

    devShells = forAllSystems (system: import ./shell.nix {pkgs = nixpkgs.legacyPackages.${system};});
  };
}
