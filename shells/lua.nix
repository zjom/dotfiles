# Lua toolchain. The language server and stylua are also in the global profile,
# because the Neovim configuration is written in Lua. This shell is for projects
# that also need an interpreter and luarocks.
#   nix develop '~/dotfiles#lua'
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
