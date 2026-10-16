# Leaf node: fd.
#
# fd has no flag that skips its global ignore file (~/.config/fd/ignore). A
# change of XDG_CONFIG_HOME for fd also applies to each child process of
# `fd --exec`. Thus, the ignore patterns come from --ignore-file. If a global
# ignore file exists, fd adds its patterns to these patterns. No file in this
# repository writes a global ignore file (decision D20).
{ leaf, ... }:
{
  nodes.fd = leaf "fd" (
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
      wrappers.fd =
        { config, ... }:
        {
          package = pkgs.fd;
          constructFiles.ignore = {
            relPath = "share/fd/ignore";
            content = lib.concatLines ignores;
          };
          flags."--ignore-file" = config.constructFiles.ignore.path;
        };
    }
  );
}
