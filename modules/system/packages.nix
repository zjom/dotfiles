# Packages wanted on every host that are not configured programs, so they are
# not nodes. Host-only packages go in that host's module under modules/hosts;
# the list is merged, so a host appends rather than replaces.
#
# Language toolchains deliberately do not live here -- they belong to the dev
# shells under shells/.
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

          # gitignore fetcher, built from its own flake rather than nixpkgs.
          inputs.get-ignore.packages.${pkgs.stdenv.hostPlatform.system}.default
        ]
        # secret-tool, to store the keyring entries the bitwarden node reads.
        ++ lib.optional stdenv.hostPlatform.isLinux libsecret;
    };
in
{
  flake.modules.nixos.base = packages;
  flake.modules.darwin.base = packages;
}
