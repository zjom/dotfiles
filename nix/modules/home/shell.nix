# One definition of the interactive shell, applied to both bash and zsh, so a
# host's login shell is a detail rather than a fork of the configuration.
{ config, ... }:

let
  cfg = config.my.shell;
in
{
  my.shell.aliases = {
    c = "clear";
    clean = "sudo nix-collect-garbage -d";
    ff = "open_in_nvim";
    lg = "lazygit";
    ls = "eza --icons always";
    tm = "tmux";
    tree = "eza --icons always --tree";
  };

  my.shell.initExtra = ''
    # Fuzzy-find a file and open it in nvim. Aliased to `ff`.
    open_in_nvim() {
      local query="''${1:-}"
      local result
      result=$(fd --type f --hidden --follow \
                  --exclude=.git --exclude=node_modules --exclude=.venv --exclude=.DS_Store . \
                | fzf --query "$query" \
                      --preview 'bat --color=always --style=numbers {} 2>/dev/null || file --brief {}' \
                      --bind 'focus:transform-header:file --brief {}')

      if [[ -n "$result" ]]; then
        nvim "$result"
      else
        echo "No file selected."
      fi
    }
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.bash = {
    enable = true;
    shellAliases = cfg.aliases;
    initExtra = cfg.initExtra;
  };

  programs.zsh = {
    enable = true;
    shellAliases = cfg.aliases;
    initContent = cfg.initExtra;
  };
}
