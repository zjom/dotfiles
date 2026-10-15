# Composite node: browse files and list files. This node contains only the glue
# between fish, tmux, ranger and eza.
{ config, ... }:
{
  nodes.files = {
    imports = with config.nodes; [
      fish
      tmux
      ranger
      eza
    ];

    entry = "fish";

    wrappers.fish = {
      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -a";
        lla = "eza -la";
        lt = "eza --tree";
        tree = "eza --tree";
        rc = "ranger_cd";
      };

      configFile.content = ''
        function ranger_cd --description "Ranger, cd-ing the shell to wherever it was left"
            set -q argv[1]; or set argv $PWD
            set -l tmp (mktemp)
            command ranger --choosedir=$tmp -- $argv
            if test -f $tmp
                read -l dir <$tmp
                test -n "$dir"; and test "$dir" != "$PWD"; and cd -- $dir
                rm -f $tmp
            end
        end

        if status is-interactive
            for mode in default insert
                bind -M $mode alt-r ranger repaint
                bind -M $mode alt-R ranger_cd repaint
            end
        end
      '';
    };

    wrappers.tmux.configAfter = ''
      bind -N "Popup ranger" "c-r" popup -E -w 90% -h 90% "ranger"
    '';
  };
}
