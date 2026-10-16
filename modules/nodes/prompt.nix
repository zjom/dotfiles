# Composite node: the commands that fish runs before each prompt. This node
# contains only the fish hooks of starship, zoxide and direnv.
{ config, ... }:
let
  inherit (config) nodes;
in
{
  nodes.prompt =
    { config, pkgs, ... }:
    {
      imports = with nodes; [
        fish
        direnv
      ];

      packages = [
        pkgs.starship
        pkgs.zoxide
      ];

      entry = "fish";

      wrappers.fish = {
        # `direnv hook` writes the path of the unwrapped binary into the hook.
        # Thus, the hook runs direnv without the DIRENV_CONFIG value of the
        # wrapper. This setting gives the configuration to the hook directly, as
        # a store path. direnv does not refer back to other nodes, so there is
        # no dependency cycle (decision D19).
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

              # Home Manager configures devenv on the hosts that install devenv
              # (decision D14).
              if command -q devenv
                  devenv hook fish | source
              end
          end
        '';
      };
    };
}
