# The language toolchains. The global profile does not contain these toolchains,
# so each project pins its own toolchain. To enter a shell, run
# `nix develop '~/dotfiles#rust'`. Alternatively, put the line
# `use flake ~/dotfiles#rust` in an .envrc file. direnv then enters the shell
# when you change to the directory.
#
# Each shell is a plain `{ pkgs }:` file in ../../shells, not a module.
# There is one shell in each file. A new file in that directory becomes a
# shell with the same name.
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
