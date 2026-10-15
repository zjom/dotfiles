# Leaf node: AeroSpace, the macOS tiling window manager, configured from
# ../../aerospace/aerospace.toml. The configuration is read by the server in
# AeroSpace.app, so that is the executable wrapped; bin/aerospace, the client,
# is linked unchanged. The bindings that start other programs live in the
# mac-desktop composite, merged into the parsed file.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;

  module =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    let
      toml = pkgs.formats.toml { };
      macOS = "Applications/AeroSpace.app/Contents/MacOS";
    in
    {
      imports = [ wlib.modules.default ];

      options.settings = lib.mkOption {
        inherit (toml) type;
        default = { };
        description = "aerospace.toml.";
      };

      config = {
        package = lib.mkDefault pkgs.aerospace;
        exePath = "${macOS}/AeroSpace";
        binDir = macOS;
        binName = "AeroSpace";
        # In place of ~/.aerospace.toml and ~/.config/aerospace.
        flags."--config-path" = "${toml.generate "aerospace.toml" config.settings}";
      };
    };
in
{
  nodes.aerospace =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "aerospace";
          value = module;
        })
      ];

      entry = lib.mkDefault "aerospace";

      wrappers.aerospace = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ../../aerospace/aerospace.toml);
      };
    };
}
