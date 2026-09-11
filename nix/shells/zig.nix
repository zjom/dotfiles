# Zig toolchain + zls.
#   nix develop ~/dotfiles/nix#zig
{ pkgs }:

pkgs.mkShell {
  name = "zig-dev";

  packages = with pkgs; [
    zig
    zls
    lldb # `zig build` debug info is DWARF; lldb handles it best.
  ];

  # zls resolves builtins and std against this instead of guessing.
  env.ZIG_LIB_DIR = "${pkgs.zig}/lib/zig";

  shellHook = ''
    echo "zig $(zig version) | zls $(zls --version)"
  '';
}
