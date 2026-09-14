# System level settings shared by every macOS host.
{ config, username, ... }:

{
  # Nix itself is installed and updated outside this flake, by the Lix
  # installer, which owns /etc/nix/nix.conf and the nix-daemon launchd job.
  # Leaving this off keeps nix-darwin away from both.
  #
  # To hand the daemon over to nix-darwin instead, set `nix.enable = true`
  # with `nix.package = pkgs.lix`, and first move /etc/nix/nix.conf aside so
  # activation is allowed to replace it. Only then do the `nix.settings` and
  # `nix.gc` options in nixos.nix have a counterpart here.
  nix.enable = false;

  # Makes /etc/zshrc and /etc/bashrc load the Nix profiles, which is what puts
  # the Home Manager environment on PATH for a login shell. fish is the login
  # shell (common.nix); these keep scripts and a fallback shell working.
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # nix-darwin only sets `users.users.<name>.shell` for users in `knownUsers`,
  # which it warns against for the admin user. Set the login shell directly.
  environment.shells = [ config.programs.fish.package ];
  system.activationScripts.postActivation.text = ''
    fish=/run/current-system/sw/bin/fish
    if [ "$(dscl . -read /Users/${username} UserShell)" != "UserShell: $fish" ]; then
      echo "setting login shell of ${username} to $fish..." >&2
      dscl . -create /Users/${username} UserShell "$fish"
    fi
  '';
}
