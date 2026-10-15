# Where the dotfiles checkout lives on the machine.
# Configuration that is edited far more often than it is rebuilt is kept as a
# live symlink into the checkout (`mkOutOfStoreSymlink`) instead of a copy in
# the Nix store, so it can be edited without a rebuild; the feature modules
# that do so read `my.dotfilesRoot`.
{
  flake.modules.homeManager.base =
    { config, lib, ... }:
    let
      inherit (lib) mkOption types;
    in
    {
      options.my = {
        dotfilesRoot = mkOption {
          type = types.str;
          default = "${config.home.homeDirectory}/dotfiles";
          defaultText = "\${config.home.homeDirectory}/dotfiles";
          description = ''
            Working copy of the dotfiles repository. Configuration that is
            edited far more often than it is rebuilt is symlinked out of the
            Nix store into this checkout, so edits take effect immediately.
          '';
        };
      };
    };
}
