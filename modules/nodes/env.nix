# Composite node: the whole command line environment, and the flake's
# default package. It adds nothing of its own; every glue line lives in the
# composite that owns it.
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
      ];

      # The composites above start different programs (fish, nvim, lazygit,
      # git); this is the choice between them (decision D8).
      entry = lib.mkForce "fish";
    };
}
