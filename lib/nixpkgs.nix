# One nixpkgs for the hosts and for `nix run`, so a node builds to the same
# store path for each installation method. import-tree skips the overlays,
# because their names start with `_`.
{ inputs, ... }:

let
  overlays = [
    (import ./overlays/_nautilus.nix)
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
