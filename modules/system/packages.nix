# The packages for each host that are not configured programs. Thus, these
# packages are not nodes. A package for only one host goes in the module of that
# host under modules/hosts. The module system merges the lists, so a host adds
# packages to this list and does not replace it.
#
# This list intentionally does not contain language toolchains. Language
# toolchains belong to the dev shells under shells/.
{ inputs, ... }:

let
  packages =
    { lib, pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          bottom
          claude-code
          file
          jq
          nb
          nixd
          nixfmt
          oxfmt
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
