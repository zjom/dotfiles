# Leaf node: AeroSpace, the tiling window manager for macOS. The configuration
# comes from ../../aerospace/aerospace.toml. The server in AeroSpace.app reads
# the configuration, so the wrapper wraps that executable. The wrapper links
# bin/aerospace, the client, without changes. The bindings that start other
# programs are in the mac-desktop composite. That composite merges the bindings
# into the parsed file.
{ leaf, ... }:
let
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
        # This file replaces ~/.aerospace.toml and ~/.config/aerospace.
        flags."--config-path" = "${toml.generate "aerospace.toml" config.settings}";
      };
    };
in
{
  nodes.aerospace =
    leaf
      {
        name = "aerospace";
        inherit module;
      }
      (
        { lib, ... }:
        {
          wrappers.aerospace = {
            settings = builtins.fromTOML (builtins.readFile ../../aerospace/aerospace.toml);
          };
        }
      );
}
