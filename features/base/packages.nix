# Host tools: programs without configuration that no node calls. `nix run`
# does not see this list, so a program that the glue of a node calls goes in
# the `packages` of that node. The project toolchains are in the dev shells
# (shells/). cargo, nodejs and python3 here are for ad-hoc use.
{ inputs, ... }:

let
  packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bottom
        cargo
        claude-code
        jq
        nixd
        nixfmt
        nodejs_26
        oxfmt
        python3
        shfmt
        tombi
        unzip
        wget

        inputs.get-ignore.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.leeth.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
in
{
  flake.modules.nixos.base = packages;
  flake.modules.darwin.base = packages;
}
