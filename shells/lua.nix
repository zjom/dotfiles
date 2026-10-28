{ pkgs }:

pkgs.mkShell {
  name = "lua-dev";

  packages = with pkgs; [
    lua5_4
    lua54Packages.luarocks

    lua-language-server
    stylua
  ];

  shellHook = ''
    echo "$(lua -v) | lua-ls"
  '';
}
