# fd has no flag that skips ~/.config/fd/ignore, and a change of XDG_CONFIG_HOME
# also applies to the child processes of `fd --exec`. Thus, the patterns come
# from --ignore-file.
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
