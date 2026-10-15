# Where the lower-level modules live. Each option holds deferred modules by
# name; any file may add to a name, and every contribution merges into it.
#
#   base    -- every host (nixos, darwin, homeManager)
#   desktop -- the niri session (nixos, homeManager)
#   gui     -- hosts with a display of their own (homeManager)
{ lib, ... }:

let
  store =
    class:
    lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = { };
      description = "${class} modules, by name.";
    };
in
{
  options = {
    nixos = store "NixOS";
    darwin = store "nix-darwin";
    homeManager = store "Home Manager";
  };
}
