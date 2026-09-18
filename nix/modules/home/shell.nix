# The interactive shell. fish is the login shell on every host (see
# modules/system/{nixos,darwin}.nix); bash and zsh are left unconfigured.
{ config, ... }:

let
  cfg = config.my.shell;

  # fzf's file preview, shared by `ff` and `nr`.
  fzfPreview = "--preview 'bat --color=always --style=numbers {} 2>/dev/null || file --brief {}' --bind 'focus:transform-header:file --brief {}'";
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
    oc = "opencode";
  };

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

  programs.fish = {
    enable = true;
    shellAliases = cfg.aliases;
    interactiveShellInit = ''
      set -g fish_greeting

      # Installed outside Nix; source them only where they exist.
      test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish 2>/dev/null
      test -f ~/Library/Google/google-cloud-sdk/path.fish.inc; and source ~/Library/Google/google-cloud-sdk/path.fish.inc
    '';

    # Each lands in ~/.config/fish/functions, so they autoload in
    # non-interactive shells too -- tmux.conf runs `fish -c ranger_sesh`.
    functions = {
      open_in_nvim = {
        description = "Fuzzy-find a file and open it in nvim";
        body = ''
          set -l result (fd --type f --hidden --follow \
                            --exclude=.git --exclude=node_modules --exclude=.venv --exclude=.DS_Store . \
                          | fzf --query "$argv[1]" ${fzfPreview})

          if test -n "$result"
              nvim $result
          else
              echo "No file selected."
          end
        '';
      };

      open_in_nvim_rg = {
        description = "Pick a file whose contents match, and open it in nvim";
        body = ''
          set -l result (rg --files-with-matches --smart-case --hidden "$argv[1]" \
                          | fzf ${fzfPreview})

          if test -n "$result"
              nvim $result
          else
              echo "No file selected."
          end
        '';
      };

      ranger_cd = {
        description = "Ranger, cd-ing the shell to wherever it was left";
        body = ''
          set -q argv[1]; or set argv $PWD
          set -l tmp (mktemp)
          command ranger --choosedir=$tmp -- $argv
          if test -f $tmp
              read -l dir <$tmp
              test -n "$dir"; and test "$dir" != "$PWD"; and cd -- $dir
              rm -f $tmp
          end
        '';
      };

      ranger_sesh = {
        description = "Ranger, then open or attach a session in the chosen directory";
        body = ''
          set -q argv[1]; or set argv $PWD
          set -l tmp (mktemp)
          command ranger --choosedir=$tmp -- $argv
          set -l dir
          test -f $tmp; and read dir <$tmp
          rm -f $tmp
          test -z "$dir"; and return
          sesh connect $dir
        '';
      };

      sesh_sessions = {
        description = "Pick a session with fzf in the current pane";
        body = ''
          set -l session (sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
          commandline -f repaint
          test -z "$session"; and return
          sesh connect $session
        '';
      };

      # Kept in sync with the `c-o` binding in tmux/tmux.conf.
      sesh_all = {
        description = "The full sesh picker, in a tmux popup";
        body = ''
          set -l session (
            sesh list --icons | fzf-tmux -p 80%,70% \
              --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
              --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
              --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
              --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
              --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
              --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
              --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
              --preview-window 'right:55%' \
              --preview 'sesh preview {}'
          )
          commandline -f repaint
          test -z "$session"; and return
          sesh connect $session
        '';
      };

      activate_dev_shell = {
        description = "Activate a dev shell";
        body = ''
          set -l flake_root ${config.my.flakeRoot}
          set -l shell (fd --type f --extension nix . $flake_root/shells --exec echo '{/.}' \
                        | sort \
                        | fzf --prompt='dev shell ⚡ ' --height=40% --reverse --border)

          if test -n "$shell"
              # nix develop exports $SHELL as the dev shell's bash. Anything
              # started from here (tmux above all) would inherit it, so carry
              # the real login shell through.
              set -l outer_shell $SHELL
              nix develop "$flake_root#$shell" -c env SHELL=$outer_shell fish
          else
              echo "No dev shell selected."
          end
        '';
      };
    };

    binds = {
      "alt-s".command = "sesh_sessions";
      "alt-S".command = "sesh_all";
      "f12".command = "activate_dev_shell";
    };
  };
}
