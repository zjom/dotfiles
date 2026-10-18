# doen reads `$DOEN_CONFIG` instead of ~/.config/doen/config.yaml. A key in
# `<store>/.doen.yaml` still replaces the same key of `settings`.
{ leaf, inputs, ... }:
let
  # The home-manager module of doen writes to ~/.config, so this module wraps
  # doen instead.
  module =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    let
      yaml = pkgs.formats.yaml { };
    in
    {
      imports = [ wlib.modules.default ];

      options = {
        settings = lib.mkOption {
          inherit (yaml) type;
          default = { };
          description = "doen's config.yaml. A key that is not set keeps the default of doen.";
        };

        notesDir = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "The store, exported as `DOEN_NOTES_DIR`. If null, doen uses ~/doen.";
        };
      };

      config = {
        package = lib.mkDefault inputs.doen.packages.${pkgs.stdenv.hostPlatform.system}.default;
        env = {
          DOEN_CONFIG = "${yaml.generate "config.yaml" config.settings}";
        }
        // lib.optionalAttrs (config.notesDir != null) { DOEN_NOTES_DIR = config.notesDir; };
        # git_autocommit runs git. A git on PATH comes first.
        suffixVar = lib.optional (config.settings.git_autocommit or false) [
          "PATH"
          ":"
          (lib.makeBinPath [ pkgs.git ])
        ];
      };
    };
in
{
  nodes.doen = leaf { name = "doen"; inherit module; } { };
}
