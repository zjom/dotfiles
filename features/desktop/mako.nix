{ leaf, ... }:
{
  nodes.mako = leaf "mako" (
    { config, ... }:
    let
      inherit (config.settings) colors;
    in
    {
      wrappers.mako.settings = with colors; {
        font = "JetBrains Mono 10";
        background-color = "#${inactiveBg}";
        text-color = "#${fg}";
        border-color = "#${line}";
        progress-color = "over #${visual}";

        width = 360;
        height = 160;
        # The outer margin matches the niri gaps.
        outer-margin = 8;
        margin = 8;
        padding = "12,14";
        border-size = 1;
        border-radius = 4;

        icons = true;
        max-icon-size = 40;
        icon-location = "left";

        # The app name is a small dim line above the bold summary.
        format = "<span size='small' foreground='#${comment}'>%a</span>\\n<b>%s</b>\\n%b";
        markup = true;
        max-visible = 5;
        sort = "-time";
        layer = "overlay";
        anchor = "top-right";
        default-timeout = 5000;

        "urgency=low" = {
          text-color = "#${floatBorder}";
        };
        "urgency=high" = {
          border-color = "#${error}";
          default-timeout = 0;
        };
        # Grouped notifications show the count after the app name.
        "grouped" = {
          format = "<span size='small' foreground='#${comment}'>%a · %g</span>\\n<b>%s</b>\\n%b";
        };
        "mode=do-not-disturb" = {
          invisible = 1;
        };
      };
    }
  );

  # D-Bus activates mako through its own (changed) service file.
  flake.modules.homeManager.desktop =
    { osConfig, ... }:
    {
      services.mako = {
        enable = true;
        package = osConfig.wrappers.mako.wrapper;
      };
    };
}
