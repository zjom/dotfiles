# The only custom machinery of this repository. This file defines a node and
# makes each node a `nix run` target. All other machinery is upstream tooling.
{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkOption types;

  # A node is a module that configures `wrappers.<program>` options. Each node
  # gets a stable `key`. Thus, the module system imports each node only one
  # time, independent of the number of paths that import the node. Because of
  # this key, overlapping nodes on one host (fish and shell) merge into one
  # fish. The `flake.modules` option of flake-parts does not set a key, so this
  # file sets the key.
  keyed = name: module: {
    key = "env-graph:node:${name}";
    _file = "env-graph node `${name}`";
    imports = [
      config.graph.base
      module
    ];
  };

  # The standalone evaluation for `nix run`, without NixOS and without darwin.
  evalNode =
    pkgs: node:
    (lib.evalModules {
      class = "envGraph";
      modules = [
        node
        { _module.args.pkgs = pkgs; }
      ];
    }).config;

  wlib = inputs.wrappers.lib;

  # Builds a leaf node from its name and its body. The spec is the wrapper name,
  # or { name; entry ? name; module ? <upstream module or wlib.modules.default>; }.
  leaf =
    spec: body:
    let
      s = if builtins.isString spec then { name = spec; } else spec;
      inherit (s) name;
    in
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          inherit name;
          value = s.module or (wlib.wrapperModules.${name} or wlib.modules.default);
        })
        body
      ];
      entry = lib.mkDefault (s.entry or name);
      wrappers.${name}.enable = true;
    };

  enabledWrappers = cfg: lib.filter (w: w.enable) (lib.attrValues cfg.wrappers);

  # A node is a target on a system only if each program of the node has a
  # package on that system. A missing package throws, which also counts as
  # "not available".
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
      paths = map (w: w.wrapper) enabled ++ cfg.packages;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # The sibling programs come first on PATH. Thus, the glue of a composite
      # ("tmux", "fish") always starts the configured program, never a program
      # that is installed on the system.
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
    # nixpkgs 26.11 removed x86_64-darwin.
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    _module.args.leaf = leaf;

    graph.base = { lib, ... }: {
      options.entry = mkOption {
        type = types.str;
        description = ''
          Binary `nix run` launches. Leaves set it with mkDefault; a composite
          of two leaves must pick one (otherwise: conflict error). Unused on hosts.
        '';
      };

      options.packages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Programs without configuration. On PATH under `nix run`; system packages on hosts.";
      };
    };

    flake.modules.nixos.base =
      { config, ... }:
      {
        environment.systemPackages = config.packages;
      };
    flake.modules.darwin.base =
      { config, ... }:
      {
        environment.systemPackages = config.packages;
      };

    perSystem = { pkgs, ... }: {
      packages =
        lib.mapAttrs (mkEnv pkgs) (lib.filterAttrs (available pkgs) config.nodes)
        // lib.optionalAttrs (config.nodes ? env) { default = mkEnv pkgs "env" config.nodes.env; };
      checks = lib.mapAttrs (mkEnv pkgs) (lib.filterAttrs (available pkgs) config.nodes);
    };

    # Publish the nodes for the flakes of other people. `generic` means that
    # each module class (nixos, darwin, homeManager) can import the node.
    flake.modules.generic = config.nodes;
  };
}
