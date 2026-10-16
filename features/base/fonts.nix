# JetBrains Mono is the monospace font of all programs.
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
