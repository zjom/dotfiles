# The only piece of custom machinery. Defines what a node is and turns
# every node into a `nix run` target. Everything else is upstream tooling.
{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkOption types;

  # A node is a module that configures `wrappers.<program>` options.
  # Each one gets a stable `key`, so the module system deduplicates it no
  # matter how many paths import it. That is what makes overlapping nodes
  # on one host (fish + shell) merge into a single fish instead of two.
  # (flake-parts' `flake.modules` does not set a key, so we do it here.)
  keyed = name: module: {
    key = "env-graph:node:${name}";
    _file = "env-graph node `${name}`";
    imports = [
      config.graph.base
      module
    ];
  };

  # Standalone evaluation for `nix run`: no NixOS, no darwin.
  evalNode =
    pkgs: node:
    (lib.evalModules {
      class = "envGraph";
      modules = [
        node
        { _module.args.pkgs = pkgs; }
      ];
    }).config;

  enabledWrappers = cfg: lib.filter (w: w.enable) (lib.attrValues cfg.wrappers);

  # A node is a target on a system only where every program in it is
  # packaged: the desktop nodes are Linux-only (decision D18). A package
  # that is missing altogether throws, which counts as unavailable.
  available =
    pkgs: _: node:
    (builtins.tryEval (
      lib.all (w: lib.meta.availableOn pkgs.stdenv.hostPlatform w.package) (
        enabledWrappers (evalNode pkgs node)
      )
    )).value;

  mkEnv =
    pkgs: name: node:
    let
      cfg = evalNode pkgs node;
      enabled = enabledWrappers cfg;
    in
    pkgs.symlinkJoin {
      name = "env-${name}";
      paths = map (w: w.wrapper) enabled;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # Siblings come first on PATH, so a composite's glue ("tmux", "fish")
      # always reaches the configured program, never a system-installed one.
      postBuild = ''
        wrapProgram $out/bin/${cfg.entry} --prefix PATH : $out/bin
      '';
      meta.mainProgram = cfg.entry;
    };
in
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  options = {
    nodes = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
      apply = lib.mapAttrs keyed;
      description = "Environment nodes. Each one is a `nix run` target and a NixOS/darwin/home-manager module.";
    };

    graph.base = mkOption {
      type = types.deferredModule;
      apply = m: {
        key = "env-graph:base";
        imports = [ m ];
      };
      description = "Options shared by all nodes (entry, settings). Imported into every node automatically.";
    };
  };

  config = {
    # nixpkgs 26.11 dropped x86_64-darwin (decision D16).
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    graph.base = { lib, ... }: {
      options.entry = mkOption {
        type = types.str;
        description = ''
          Binary `nix run` launches. Leaves set it with mkDefault; a composite
          of two leaves must pick one (otherwise: conflict error). Unused on hosts.
        '';
      };
    };

    perSystem = { pkgs, ... }: {
      packages =
        lib.mapAttrs (mkEnv pkgs) (lib.filterAttrs (available pkgs) config.nodes)
        // lib.optionalAttrs (config.nodes ? env) { default = mkEnv pkgs "env" config.nodes.env; };
      checks = lib.mapAttrs (mkEnv pkgs) (lib.filterAttrs (available pkgs) config.nodes);
    };

    # Publish nodes for other people's flakes. `generic` = importable into
    # any module class (nixos, darwin, homeManager).
    flake.modules.generic = config.nodes;
  };
}
