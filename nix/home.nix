{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  home.username = "zi";
  home.homeDirectory = "/home/zi";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    bat
    claude-code
    file
    gcc
    github-cli
    neovim
    nixfmt
    nodejs
    python3
    tmux
    tree-sitter
    unzip
  ];

  xdg.configFile = {
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/tmux/.config/tmux";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim/.config/nvim";
  };

  programs = {
    bash = {
      enable = true;
      initExtra = ''
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
      sessionVariables = {
        EDITOR = "nvim";
      };
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch";
        clean = "sudo nix-collect-garbage -d";
        ls = "eza --icons always";
        tree = "eza --icons always --tree";
        c = "clear";
        lg = "lazygit";
        tm = "tmux";
        ff = "open_in_nvim";
      };
    };
    eza = {
      enable = true;
      enableBashIntegration = true;
    };
    fd = {
      enable = true;
      ignores = [
        ".git"
        ".jj"
        "node_modules"
        ".venv"
        "venv"
      ];
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
      tmux = {
        enableShellIntegration = true;
      };
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "Zihan Jin";
          email = "admin@zihanjin.com";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
    lazygit = {
      enable = true;
    };
    ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--smart-case"
        "--glob=!.git/*"
        "--glob=!node_modules/*"
        "--glob=!.venv/*"
        "--glob=!venv/*"
        "--glob=!.DS_Store"
        "--glob=!.git/*"
      ];
    };
    sesh = {
      enable = true;
      enableTmuxIntegration = true;
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

}
