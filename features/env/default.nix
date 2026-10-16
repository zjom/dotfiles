# The full command-line environment, and the default package of the flake.
{ config, ... }:
{
  nodes.env =
    { lib, ... }:
    {
      imports = with config.nodes; [
        shell
        search
        editor
        git-ui
        devshell
        bitwarden
        nh
        spotify-player
      ];

      # The imported composites start different programs.
      entry = lib.mkForce "fish";
    };
}
