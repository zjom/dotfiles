# The packages without configuration for each host. The language toolchains
# are in the dev shells (shells/).
{ inputs, ... }:

let
  packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bottom
        cargo
        claude-code
        file
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
