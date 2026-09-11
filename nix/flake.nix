{
  description = "My NixOS-WSL config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Per-language toolchains, kept out of the global profile so projects
      # pin what they need: `nix develop ~/dotfiles/nix#rust`.
      devShells.${system} = {
        rust = import ./shells/rust.nix { inherit pkgs; };
        zig = import ./shells/zig.nix { inherit pkgs; };
        c = import ./shells/c.nix { inherit pkgs; };
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.zi = import ./home.nix;
          }
        ];
      };
    };
}
