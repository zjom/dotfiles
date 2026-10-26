{ leaf, ... }:
{
  # kitty resolves `include theme.conf` relative to the generated file. Thus,
  # the include points to a theme in the store, made from the colour settings.
  nodes.kitty = leaf "kitty" (
    { config, pkgs, ... }:
    let
      theme = pkgs.writeText "theme.conf" (
        with config.settings.colors;
        ''
          # vim:ft=kitty
          ## name:     Vague
          ## author:   skewb1k
          ## license:  MIT
          ## upstream: https://github.com/vague-theme/vague-kitty/blob/main/vague.conf

          foreground               #${fg}
          background               #${bg}
          selection_foreground     #${fg}
          selection_background     #${line}
          cursor                   none
          url_color                #${purple}

          color0   #${line}
          color8   #${comment}
          color1   #${error}
          color9   #${brightRed}
          color2   #${plus}
          color10  #${brightGreen}
          color3   #${warning}
          color11  #${brightYellow}
          color4   #${keyword}
          color12  #${brightBlue}
          color5   #${purple}
          color13  #${brightPurple}
          color6   #${cyan}
          color14  #${brightCyan}
          color7   #${fg}
          color15  #${brightWhite}

          active_tab_foreground    #${fg}
          active_tab_background    #${line}
          inactive_tab_foreground  #${comment}
          inactive_tab_background  #${bg}
        ''
      );
    in
    {
      wrappers.kitty.extraConfig =
        builtins.replaceStrings [ "include theme.conf" ] [ "include ${theme}" ]
          (builtins.readFile ./kitty.conf);
    }
  );
}
