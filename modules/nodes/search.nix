# Composite node: finding files and text from fish, and opening them in
# Neovim. Owns only the glue between fish, fzf, fd, ripgrep, bat and nvim.
{ config, ... }:
let
  # fzf's file preview, shared by `ff` and `nr`.
  fzfPreview = "--preview 'bat --color=always --style=numbers {} 2>/dev/null || file --brief {}' --bind 'focus:transform-header:file --brief {}'";
in
{
  nodes.search = {
    imports = with config.nodes; [
      fish
      fzf
      fd
      ripgrep
      bat
      nvim
    ];

    entry = "fish";

    wrappers.fish = {
      shellAliases = {
        cat = "bat";
        ff = "open_in_nvim";
        nr = "open_in_nvim_rg";
      };

      env.PAGER = "bat";

      configFile.content = ''
        # ctrl-t, ctrl-r and alt-c.
        if status is-interactive
            fzf --fish | source
        end

        function open_in_nvim --description "Fuzzy-find a file and open it in nvim"
            set -l result (fd --type f --hidden --follow \
                              --exclude=.git --exclude=node_modules --exclude=.venv --exclude=.DS_Store . \
                            | fzf --query "$argv[1]" ${fzfPreview})

            if test -n "$result"
                nvim $result
            else
                echo "No file selected."
            end
        end

        function open_in_nvim_rg --description "Pick a file whose contents match, and open it in nvim"
            set -l result (rg --files-with-matches --smart-case --hidden "$argv[1]" \
                            | fzf ${fzfPreview})

            if test -n "$result"
                nvim $result
            else
                echo "No file selected."
            end
        end
      '';
    };
  };
}
