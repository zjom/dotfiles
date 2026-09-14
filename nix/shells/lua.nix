# Lua toolchain + lua-language-server. The language server and stylua are also
# in the global profile, since Neovim's own configuration is Lua; this shell is
# for projects that need an interpreter and luarocks as well.
#   nix develop '~/dotfiles/nix#lua'
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
    echo "$(lua -v) | luarocks | lua-language-server"
  '';
}
