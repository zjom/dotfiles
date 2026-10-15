# The packages for each host that are not configured programs. Thus, these
# packages are not nodes. A package for only one host goes in the module of that
# host under modules/hosts. The module system merges the lists, so a host adds
# packages to this list and does not replace it.
#
# The dev shells under shells/ contain the full language toolchains. This list
# contains only the base interpreters and cargo, for scripts and one-off
# commands outside a dev shell.
{ inputs, ... }:

let
  packages =
    { lib, pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          bottom
          cargo
          claude-code
          file
          jq
          nb
          nixd
          nixfmt
          nodejs_26
          oxfmt
          python3
          shfmt
          tombi
          unzip
          wget

          # A tool that fetches gitignore templates, built from its own flake,
          # not from nixpkgs.
          inputs.get-ignore.packages.${pkgs.stdenv.hostPlatform.system}.default
        ]
        # secret-tool, to store the keyring entries that the bitwarden node
        # reads.
        ++ lib.optional stdenv.hostPlatform.isLinux libsecret;
    };
in
{
  flake.modules.nixos.base = packages;
  flake.modules.darwin.base = packages;
}
