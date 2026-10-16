# The same fonts on each host. JetBrains Mono is the monospace font for all
# programs (kitty, waybar, lm10, swaylock). kitty draws the Nerd Font symbols
# itself. Other programs use Symbols Nerd Font as a fallback.
let
  fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        fira-code
        hack-font
        jetbrains-mono
        nerd-fonts.meslo-lg
        nerd-fonts.symbols-only
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];
    };
in
{
  flake.modules.nixos.base = {
    imports = [ fonts ];

    # macOS has no fontconfig.
    fonts.fontconfig.defaultFonts = {
      monospace = [ "JetBrains Mono" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  flake.modules.darwin.base = fonts;
}
