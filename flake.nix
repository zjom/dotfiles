{
  description = "Zihan's NixOS, nix-darwin and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # The top-level configuration that contains each file under ./modules, and
    # the importer that loads these files.
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    # Wrapper modules. Each wrapper module puts the configuration of a program
    # into the package of that program. The input also contains install modules
    # that supply `wrappers.<name>` on NixOS, nix-darwin and Home Manager. For
    # more information, see modules/graph.nix.
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The system layer for macOS. The Linux hosts use the NixOS modules that are
    # part of nixpkgs, so the Linux hosts need no equivalent input.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Only modules/hosts/wsl.nix imports this input.
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A tool that fetches gitignore templates. modules/system/packages.nix
    # installs it.
    get-ignore = {
      url = "github:zjom/get-ignore";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The picker menu that is the launcher of the session.
    # modules/system/desktop/session.nix installs it.
    lm10 = {
      url = "github:zjom/lm10";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zen-draw. modules/hosts/loq installs it.
    zen-draw = {
      url = "github:zjom/zen-draw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Each file under ./modules is a flake-parts module, and import-tree imports
  # each file. Each file contains one feature. A file adds configuration to each
  # layer that the feature uses: NixOS, nix-darwin, Home Manager or more than
  # one of these layers. For more information, see README.md.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
