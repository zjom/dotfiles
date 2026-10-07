# Packages wanted on every host that belong to no feature of their own.
# Host-only packages go in that host's module under modules/hosts; the list is
# merged, so a host appends rather than replaces.
#
# Language toolchains deliberately do not live here -- they belong to the dev
# shells under nix/shells.
{ inputs, ... }:

{
  homeManager.base =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bottom
        file
        jq
        markdown-oxide
        nixd
        nixfmt
        oxfmt
        tombi
        unzip
        wget

        # gitignore fetcher, built from its own flake rather than nixpkgs.
        inputs.get-ignore.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
