{ pkgs }:

pkgs.mkShell {
  name = "infra-dev";

  packages = with pkgs; [
    opentofu
    opentofu-ls
    awscli2
  ];

  shellHook = ''
    echo "opentofu | aws"
  '';
}
