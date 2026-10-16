# fish, the login shell on each host. This fish is the wrapped fish of
# nodes.fish, with the composites that the host adds. bash and zsh are
# installed, but bash and zsh have no configuration of their own.
#
# fish reads /etc/fish/config.fish by itself (decision D22). NixOS and
# nix-darwin use that file to set PATH and the other environment variables.
{ config, ... }:

let
  inherit (config) nodes;

  loginShell =
    { config, ... }:
    {
      imports = [ nodes.fish ];

      # The fish of the system is the wrapper itself. Thus,
      # /run/current-system/sw/bin/fish is the configured fish, and the two fish
      # packages do not conflict in systemPackages.
      programs.fish = {
        enable = true;
        package = config.wrappers.fish.wrapper;
      };
      environment.shells = [ config.programs.fish.package ];
    };
in
{
  flake.modules.nixos.base =
    { config, ... }:
    {
      imports = [ loginShell ];
      users.users.${config.my.username}.shell = config.programs.fish.package;
    };

  flake.modules.darwin.base =
    { config, ... }:
    {
      imports = [ loginShell ];

      # Makes /etc/zshrc and /etc/bashrc load the Nix profiles. These profiles
      # put the Home Manager environment on PATH for a login shell. Thus,
      # scripts and the fallback shell continue to work.
      programs.zsh.enable = true;
      programs.bash.enable = true;

      # nix-darwin sets `users.users.<name>.shell` only for users in
      # `knownUsers`. nix-darwin recommends that you do not put the admin user
      # in `knownUsers`. Thus, set the login shell directly.
      system.activationScripts.postActivation.text = ''
        fish=/run/current-system/sw/bin/fish
        if [ "$(dscl . -read /Users/${config.my.username} UserShell)" != "UserShell: $fish" ]; then
          echo "setting login shell of ${config.my.username} to $fish..." >&2
          dscl . -create /Users/${config.my.username} UserShell "$fish"
        fi
      '';
    };
}
