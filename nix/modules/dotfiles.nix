# Where the dotfiles checkout and this flake live on the machine.
# Configuration that is edited far more often than it is rebuilt is kept as a
# live symlink into the checkout (`mkOutOfStoreSymlink`) instead of a copy in
# the Nix store, so it can be edited without a rebuild; the feature modules
# that do so read `my.dotfilesRoot`.
{
  homeManager.base =
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
            edited far more often than it is rebuilt (nvim, tmux) is symlinked
            out of the Nix store into this checkout, so edits take effect
            immediately.
          '';
        };

        flakeRoot = mkOption {
          type = types.str;
          default = "${config.my.dotfilesRoot}/nix";
          defaultText = "\${config.my.dotfilesRoot}/nix";
          description = ''
            Directory holding this flake, handed to nh as NH_FLAKE. It has to
            be a path on the machine rather than a store path.
          '';
        };
      };
    };
}
