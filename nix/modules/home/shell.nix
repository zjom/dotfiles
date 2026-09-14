# One definition of the interactive shell, applied to both bash and zsh, so a
# host's login shell is a detail rather than a fork of the configuration.
{ config, ... }:

let
  cfg = config.my.shell;
in
{
  my.shell.aliases = {
    c = "clear";
    cat = "bat";
    clean = "sudo nix-collect-garbage -d";
    ff = "open_in_nvim";
    ls = "eza --icons always";
    nr = "open_in_nvim_rg";
    nv = "nvim";
    nvi = "nvim";
    nvm = "nvim";
    q = "exit";
    r = "ranger";
    rc = "ranger_cd";
    rs = "ranger_sesh";
    tm = "tmux";
    tree = "eza --icons always --tree";
    tt = "touch";
    vim = "nvim";
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

      if [ -n "$result" ]; then
        nvim "$result"
      else
        echo "No file selected."
      fi
    }

    # Same, but pick from the files whose contents match. Aliased to `nr`.
    open_in_nvim_rg() {
      local query="''${1:-}"
      local result
      result=$(rg --files-with-matches --smart-case --hidden "$query" \
                | fzf --preview 'bat --color=always --style=numbers {} 2>/dev/null || file --brief {}' \
                      --bind 'focus:transform-header:file --brief {}')

      if [ -n "$result" ]; then
        nvim "$result"
      else
        echo "No file selected."
      fi
    }

    # Ranger, cd-ing the shell to wherever it was left. Aliased to `rc`.
    ranger_cd() {
      local tmp dir
      tmp="$(mktemp)"
      command ranger --choosedir="$tmp" -- "''${@:-$PWD}"
      if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -n "$dir" ] && [ "$dir" != "$PWD" ] && cd -- "$dir"
        rm -f "$tmp"
      fi
    }

    # Ranger, then open or attach a session in the chosen directory. Aliased to `rs`.
    ranger_sesh() {
      local tmp dir
      tmp="$(mktemp)"
      command ranger --choosedir="$tmp" -- "''${@:-$PWD}"
      [ -f "$tmp" ] && dir="$(cat "$tmp")"
      rm -f "$tmp"
      [ -z "$dir" ] && return
      sesh connect "$dir"
    }
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
    PAGER = "bat";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/go/bin"
  ];

  # Defines the XDG_* variables the configs below (and ranger, gh, ...) read.
  xdg.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = cfg.aliases;
    initExtra = cfg.initExtra;
  };

  programs.zsh = {
    enable = true;
    shellAliases = cfg.aliases;
    initContent = cfg.initExtra + "\n" + cfg.zshExtra;
  };
}
