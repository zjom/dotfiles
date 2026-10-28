{
  description = "Zihan's NixOS, nix-darwin and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    get-ignore = {
      url = "github:zjom/get-ignore";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lm10 = {
      url = "github:zjom/lm10";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-draw = {
      url = "github:zjom/zen-draw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doen = {
      url = "github:zjom/doen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    leeth = {
      url = "github:zjom/leeth";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Each .nix file below these directories is a flake-parts module. import-tree skips each path that contains `/_`.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree [
        ./lib
        ./features
        ./hosts
        ./hardware
      ]
    );
}
