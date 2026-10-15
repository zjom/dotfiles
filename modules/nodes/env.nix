# Composite node: the full command-line environment, and the default package of
# the flake. This node adds no configuration of its own. Each line of glue is in
# the composite that owns it.
{ config, ... }:
{
  nodes.env =
    { lib, ... }:
    {
      imports = with config.nodes; [
        shell
        search
        files
        prompt
        editor
        git-ui
        github
        devshell
        bitwarden
        nh
        spotify-player
      ];

      # The composites above start different programs (fish, nvim, lazygit,
      # git). This setting selects one of these programs (decision D8).
      entry = lib.mkForce "fish";
    };
}
