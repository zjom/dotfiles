# The same fonts on every host. JetBrains Mono is the monospace font
# everywhere (kitty, waybar, fuzzel, swaylock); kitty draws Nerd Font symbols
# itself, other programs fall back to Symbols Nerd Font.
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
  nixos.base = {
    imports = [ fonts ];

    # macOS has no fontconfig.
    fonts.fontconfig.defaultFonts = {
      monospace = [ "JetBrains Mono" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  darwin.base = fonts;
}
