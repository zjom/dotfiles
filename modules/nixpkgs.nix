# One nixpkgs for every consumer. The hosts and the standalone `nix run`
# evaluation in graph.nix get the same overlays and the same config, so a node
# builds to the same store path whichever way it is installed (decision D11).
#
# Each overlay lives in its own `_`-prefixed file under ./overlays, so
# import-tree skips it and it stays a plain overlay. Host-only overlays stay in
# that host's module under modules/hosts.
{ inputs, ... }:

let
  overlays = [
    (import ./overlays/_sesh.nix)
  ];
  config.allowUnfree = true;

  nixpkgs = {
    nixpkgs = { inherit overlays config; };
  };
in
{
  flake.modules.nixos.base = nixpkgs;
  flake.modules.darwin.base = nixpkgs;

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs { inherit system overlays config; };
    };
}
