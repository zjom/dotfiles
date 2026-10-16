{ leaf, ... }:
{
  nodes.mako = leaf "mako" {
    wrappers.mako.settings = {
      font = "JetBrains Mono 10";
      default-timeout = 5000;
      border-radius = 4;
    };
  };

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
