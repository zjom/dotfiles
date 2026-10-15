{
  description = "Zihan's NixOS, nix-darwin and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # The top-level configuration every file under ./modules belongs to, and
    # the importer that loads them all.
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    # Wrapper modules: each program's configuration baked into its package,
    # plus install modules exposing `wrappers.<name>` on NixOS, nix-darwin and
    # Home Manager. See modules/graph.nix.
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System layer for macOS. The Linux hosts use the NixOS modules that ship
    # with nixpkgs itself, so there is no matching input for them.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Imported by modules/hosts/wsl.nix only.
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # gitignore fetcher; installed by modules/packages.nix.
    get-ignore = {
      url = "github:zjom/get-ignore";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Picker menu, the session's launcher; installed by modules/desktop/session.nix.
    lm10 = {
      url = "github:zjom/lm10";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Logitech device manager; its NixOS module is imported by modules/hosts/loq.
    openlogi = {
      url = "github:AprilNEA/OpenLogi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zen-draw; installed by modules/hosts/loq.
    zen-draw = {
      url = "github:zjom/zen-draw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Every file under ./modules is a flake-parts module, imported by
  # import-tree: one feature per file, contributing to whichever of the
  # NixOS, nix-darwin and Home Manager layers it touches. See README.md.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
