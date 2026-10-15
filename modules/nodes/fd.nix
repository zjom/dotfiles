# Leaf node: fd.
#
# fd has no flag to skip its global ignore file (~/.config/fd/ignore), and
# moving XDG_CONFIG_HOME for it would leak into every `fd --exec` child. So the
# ignores come from --ignore-file, and a hand-made global file would still add
# to them. Nothing in this repository writes one (decision D20).
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.fd =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ignores = config.settings.searchIgnores;
    in
    {
      imports = [
        (wlib.getInstallModule {
          name = "fd";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "fd";

      wrappers.fd =
        { config, ... }:
        {
          enable = true;
          package = pkgs.fd;
          constructFiles.ignore = {
            relPath = "share/fd/ignore";
            content = lib.concatLines ignores;
          };
          flags."--ignore-file" = config.constructFiles.ignore.path;
        };
    };
}
