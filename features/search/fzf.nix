# A prefix of FZF_DEFAULT_OPTS keeps the options of the caller: the ctrl-r
# widget of `fzf --fish` puts --read0, --delimiter and --ansi there.
{ leaf, ... }:
{
  nodes.fzf = leaf "fzf" (
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.settings) colors;

      palette = lib.mapAttrsToList (name: c: "${name}:#${c}") (
        with colors;
        {
          inherit fg bg;
          hl = string;
          "fg+" = fg;
          "bg+" = line;
          "hl+" = string;
          gutter = bg;
          query = fg;
          info = comment;
          border = floatBorder;
          separator = line;
          scrollbar = line;
          prompt = keyword;
          pointer = func;
          marker = plus;
          spinner = warning;
          header = comment;
        }
      );
    in
    {
      wrappers.fzf = {
        package = pkgs.fzf;
        prefixVar = [
          [
            "FZF_DEFAULT_OPTS"
            " "
            (lib.concatStringsSep " " [
              "--cycle"
              "--pointer=▎"
              "--marker=▎"
              "--walker-skip=${lib.concatStringsSep "," config.settings.searchIgnores}"
              "--color=${lib.concatStringsSep "," palette}"
            ])
          ]
        ];
        unsetVar = [ "FZF_DEFAULT_OPTS_FILE" ];
      };
    }
  );
}
