# Per-language toolchains, kept out of the global profile so projects pin what
# they need: `nix develop '~/dotfiles/nix#rust'`, or an .envrc holding
# `use flake ~/dotfiles/nix#rust` to have direnv do it on cd.
#
# The shells themselves are plain `{ pkgs }:` files in ../../shells rather than
# modules, one per file; a new file there becomes a shell of the same name.
{ lib, ... }:

let
  dir = ../../shells;
in
{
  perSystem =
    { pkgs, ... }:
    {
      devShells = lib.mapAttrs' (
        file: _:
        lib.nameValuePair (lib.removeSuffix ".nix" file) (import (dir + "/${file}") { inherit pkgs; })
      ) (builtins.readDir dir);
    };
}
