{
  description = "Zihan's NixOS, nix-darwin and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System layer for macOS. The Linux host uses the NixOS modules that ship
    # with nixpkgs itself, so there is no matching input for it.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # Builds one host. Home Manager is wired in as a system module on both
      # platforms, so a single `rebuild` activates the system and the user
      # environment together, and both read the same shared modules.
      #
      #   hosts/<name>/default.nix  -> system level, this host only
      #   hosts/<name>/home.nix     -> Home Manager level, this host only
      #   modules/system/*.nix      -> system level, shared
      #   modules/home/*.nix        -> Home Manager level, shared
      mkHost =
        {
          hostName,
          system,
          username,
        }:
        let
          isDarwin = lib.hasSuffix "-darwin" system;

          builder = if isDarwin then nix-darwin.lib.darwinSystem else lib.nixosSystem;

          hmModule =
            if isDarwin then
              home-manager.darwinModules.home-manager
            else
              home-manager.nixosModules.home-manager;

          specialArgs = {
            inherit
              inputs
              self
              hostName
              username
              ;
          };
        in
        builder {
          inherit specialArgs;

          modules = [
            { nixpkgs.hostPlatform = system; }

            ./hosts/${hostName}

            hmModule
            {
              home-manager = {
                # Reuse the system's nixpkgs (and its allowUnfree) instead of
                # instantiating a second one.
                useGlobalPkgs = true;
                useUserPackages = true;

                # Rename rather than fail when activation wants to write over a
                # file that is already there by hand.
                backupFileExtension = "hm-bak";

                extraSpecialArgs = specialArgs;

                users.${username}.imports = [
                  ./modules/home
                  ./hosts/${hostName}/home.nix
                ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations.nixos = mkHost {
        hostName = "nixos";
        system = "x86_64-linux";
        username = "zi";
      };

      darwinConfigurations.macbook = mkHost {
        hostName = "macbook";
        system = "aarch64-darwin";
        username = "zihanjin";
      };

      # Per-language toolchains, kept out of the global profile so projects
      # pin what they need: `nix develop '~/dotfiles/nix#rust'`, or an .envrc
      # holding `use flake ~/dotfiles/nix#rust` to have direnv do it on cd.
      devShells = forAllSystems (
        pkgs:
        lib.genAttrs [
          "c"
          "elixir"
          "go"
          "lua"
          "ocaml"
          "python"
          "rust"
          "typst"
          "web"
          "zig"
        ] (name: import ./shells/${name}.nix { inherit pkgs; })
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
