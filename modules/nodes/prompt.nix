# Composite node: what fish runs before each prompt. Owns only the hooks of
# starship, zoxide and direnv into fish.
{ config, ... }:
let
  inherit (config) nodes;
in
{
  nodes.prompt =
    { config, ... }:
    {
      imports = with nodes; [
        fish
        starship
        zoxide
        direnv
      ];

      entry = "fish";

      wrappers.fish = {
        # `direnv hook` writes the path of the unwrapped binary into the hook,
        # so the hook would run direnv without the wrapper's DIRENV_CONFIG.
        # Hand it the configuration directly (by store path: direnv refers to
        # nothing back, so there is no cycle).
        env.DIRENV_CONFIG = dirOf config.wrappers.direnv.constructFiles.direnvrc.outPath;

        configFile.content = ''
          if status is-interactive
              zoxide init fish | source

              if test "$TERM" != dumb
                  starship init fish | source
              end

              if not functions -q __direnv_export_eval
                  direnv hook fish | source
              end

              # devenv is configured by Home Manager, where it is installed at all
              # (decision D14).
              if command -q devenv
                  devenv hook fish | source
              end
          end
        '';
      };
    };
}
