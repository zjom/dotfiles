# Options this configuration defines for itself, under the `my` namespace so
# they can never collide with an upstream Home Manager option.
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
        Working copy of the dotfiles repository. Configuration that is edited
        far more often than it is rebuilt (nvim, tmux) is symlinked out of the
        Nix store into this checkout, so edits take effect immediately.
      '';
    };

    flakeRoot = mkOption {
      type = types.str;
      default = "${config.my.dotfilesRoot}/nix";
      defaultText = "\${config.my.dotfilesRoot}/nix";
      description = ''
        Directory holding this flake. Used to build the `rebuild` alias, so it
        has to be a path on the machine rather than a store path.
      '';
    };

    shell.aliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        gs = "git status";
      };
      description = ''
        Aliases for the interactive shell (fish). Definitions from several
        modules are merged, so a host can add to the shared set without
        restating it.
      '';
    };
  };
}
