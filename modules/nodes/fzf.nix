# Leaf node: fzf. Its options live in FZF_DEFAULT_OPTS, set on the fzf binary
# itself, so fzf-tmux and every other caller get them too.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.fzf =
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
      imports = [
        (wlib.getInstallModule {
          name = "fzf";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "fzf";

      wrappers.fzf = {
        enable = true;
        package = pkgs.fzf;
        env.FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
          "--cycle"
          "--pointer=▎"
          "--marker=▎"
          "--walker-skip=${lib.concatStringsSep "," config.settings.searchIgnores}"
          "--color=${lib.concatStringsSep "," palette}"
        ];
        unsetVar = [ "FZF_DEFAULT_OPTS_FILE" ];
      };
    };
}
