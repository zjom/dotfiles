# Zig toolchain, with zls.
#   nix develop '~/dotfiles#zig'
{ pkgs }:

pkgs.mkShell {
  name = "zig-dev";

  packages = with pkgs; [
    zig
    zls
    lldb # `zig build` writes DWARF debug info. lldb supports DWARF best.
  ];

  # zls uses this value to find the builtins and std. Without this value, zls
  # guesses.
  env.ZIG_LIB_DIR = "${pkgs.zig}/lib/zig";

  shellHook = ''
    echo "zig $(zig version) | zls $(zls --version)"
  '';
}
