# Lua toolchain + emmylua-ls. The language server and stylua are also
# in the global profile, since Neovim's own configuration is Lua; this shell is
# for projects that need an interpreter and luarocks as well.
#   nix develop '~/dotfiles/nix#lua'
{ pkgs }:

pkgs.mkShell {
  name = "lua-dev";

  packages = with pkgs; [
    lua5_4
    lua54Packages.luarocks

    emmylua-ls
    emmy-lua-code-style
    emmylua-check
    emmylua-doc-cli
    emmylua-formatter
  ];

  shellHook = ''
    echo "$(lua -v) | luarocks | emmylua"
  '';
}
