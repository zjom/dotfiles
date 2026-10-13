# Every overlay applied to nixpkgs on all hosts, in one place. Each overlay
# lives in its own `_`-prefixed file or directory beside this one, so
# import-tree skips it and it stays a plain overlay rather than a flake-parts
# module. Host-only overlays stay in that host's module under modules/hosts.
let
  overlays = [
    (import ./_sesh.nix)
  ];
in
{
  nixos.base.nixpkgs.overlays = overlays;
  darwin.base.nixpkgs.overlays = overlays;
}
