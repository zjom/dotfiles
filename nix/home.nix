{ config, pkgs, ... }:

let
  # Configs live in the dotfiles repo and are symlinked out of the nix store so they
  # stay writable (tpm clones into tmux/plugins, vim.pack writes its lockfile) and
  # editable without a rebuild.
  dotfiles = "${config.home.homeDirectory}/projects/dotfiles";
in
{
  home.username = "zi";
  home.homeDirectory = "/home/zi";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    bat
    cargo
    clang-tools
    claude-code
    clippy
    file
    gcc
    github-cli
    gnumake
    neovim
    nixfmt
    nodejs_26
    rust-analyzer
    rustc
    rustfmt
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
        export EDITOR=nvim

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
