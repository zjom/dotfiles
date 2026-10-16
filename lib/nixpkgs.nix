# One nixpkgs for all consumers. The hosts and the standalone `nix run`
# evaluation in graph.nix get the same overlays and the same config. Thus, a
# node builds to the same store path for each installation method (decision
# D11).
#
# Each overlay is in a separate file under ./overlays. The name of each file
# starts with `_`, so import-tree skips the file, and the file stays a plain
# overlay. An overlay for only one host stays in the module of that host under
# hosts/.
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
