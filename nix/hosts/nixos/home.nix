# Home Manager configuration for the WSL machine only. The shared modules are
# imported by the flake alongside this file.
{
  config,
  hostName,
  username,
  ...
}:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  my.shell.aliases.rebuild = "sudo nixos-rebuild switch --flake '${config.my.flakeRoot}#${hostName}'";
}
