# What runs inside the niri session: launcher, notifications, file
# associations, cursor and theme. The bar and locking have files of their own.
{ config, inputs, ... }:

let
  inherit (config) colors;
in
{
  homeManager.desktop =
    { lib, pkgs, ... }:
    let
      lm10 = inputs.lm10.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      home.packages = with pkgs; [
        bluetui
        brightnessctl
        imv
        playerctl
        wl-clipboard
        # niri starts it on demand to run X11 programs.
        xwayland-satellite

        # The launcher. lm10 only picks from the lines it is given; these
        # scripts feed it.
        lm10
        # Desktop applications, from lm10's own example.
        (writeShellScriptBin "lm10-apps" ''
          PATH=${
            lib.makeBinPath [
              lm10
              fd
              gnused
            ]
          }:$PATH
          exec ${lib.getExe fish} ${inputs.lm10}/examples/apps.fish
        '')
        # The sesh picker after fish's sesh_all, each pick connected to in
        # kitty. It makes its own lists (lm10-sesh --list WHAT), so the reload
        # binds can run it too. lm10 has no preview, and no way to read a new
        # name, so sesh_all's preview and ^r rename are left out.
        (writeShellApplication {
          name = "lm10-sesh";
          runtimeInputs = [
            lm10
            sesh
            fd
            gnused
          ];
          text = ''
            # Prints entries as lines, quoted with %q, which lm10 reads back.
            # The session is the last argv word: kitty --single-instance --
            # sesh connect SESSION is {5}.
            entry() {
              printf -- '-X -n %q -- kitty --single-instance -- sesh connect %q\n' "$1" "$2"
            }

            list() {
              case ''${1:-} in
              find)
                fd -H -d 2 -t d -E .Trash . ~ | while IFS= read -r dir; do
                  entry "~''${dir#"$HOME"}" "$dir"
                done
                ;;
              *)
                # The icons come coloured; lm10 shows text as is.
                sesh list --icons "$@" | sed 's/\x1b\[[0-9;]*m//g' |
                  while IFS= read -r line; do
                    entry "$line" "''${line#* }"
                  done
                ;;
              esac
            }

            if [[ ''${1:-} == --list ]]; then
              shift
              list "$@"
              exit
            fi

            printf -v self %q "$(realpath "$0")"
            list | lm10 \
              --width 40% \
              --prompt '⚡  ' \
              --header '^a  ^t  ^x  ^f  ^d' \
              --bind "Control+a=change-prompt(⚡  )+reload($self --list)" \
              --bind "Control+t=change-prompt(🪟  )+reload($self --list -t)" \
              --bind "Control+x=change-prompt(📁  )+reload($self --list -z)" \
              --bind "Control+f=change-prompt(🔎  )+reload($self --list find)" \
              --bind "Control+d=execute(tmux kill-session -t {5})+change-prompt(⚡  )+reload($self --list)"
          '';
        })
      ];

      # xdg-open under niri falls back to its generic launcher, which does not
      # honour Terminal=true, so the terminal programs get entries that start
      # kitty themselves.
      xdg.desktopEntries = {
        nvim-kitty = {
          name = "Neovim (kitty)";
          exec = "kitty nvim %F";
          noDisplay = true;
        };
        ranger-kitty = {
          name = "Ranger (kitty)";
          exec = "kitty ranger %f";
          noDisplay = true;
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          let
            # mimeapps.list has no wildcards, so every type is listed.
            for = app: types: lib.genAttrs types (_: app);
          in
          for "firefox.desktop" [
            "text/html"
            "application/xhtml+xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "application/pdf"
          ]
          // for "nvim-kitty.desktop" [
            "text/plain"
            "text/markdown"
            "text/csv"
            "text/css"
            "text/javascript"
            "text/x-python"
            "text/x-lua"
            "text/x-nix"
            "text/rust"
            "text/x-go"
            "text/x-csrc"
            "text/x-chdr"
            "text/x-c++src"
            "text/x-c++hdr"
            "text/x-log"
            "text/x-makefile"
            "application/json"
            "application/toml"
            "application/yaml"
            "application/x-yaml"
            "application/xml"
            "application/x-shellscript"
            "application/javascript"
          ]
          // for "ranger-kitty.desktop" [ "inode/directory" ]
          // for "imv.desktop" [
            "image/png"
            "image/jpeg"
            "image/gif"
            "image/webp"
            "image/bmp"
            "image/tiff"
            "image/svg+xml"
          ]
          // {
            "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
          };
      };
      # Programs rewrite this file at runtime; replace it rather than refuse to
      # switch.
      xdg.configFile."mimeapps.list".force = true;

      home.pointerCursor = {
        enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
      };

      gtk = {
        enable = true;
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      };
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      xdg.configFile."lm10/lm10.ini".text = lib.generators.toINI { } {
        main = {
          font = "JetBrains Mono 15";
          border-width = 1;
          border-radius = 4;
        };
        colors = with colors; {
          background = "#${bg}ff";
          text = "#${fg}ff";
          prompt = "#${keyword}ff";
          placeholder = "#${comment}ff";
          input = "#${fg}ff";
          cursor = "#${fg}ff";
          match = "#${string}ff";
          selection = "#${line}ff";
          selection-text = "#${fg}ff";
          selection-match = "#${string}ff";
          counter = "#${comment}ff";
          border = "#${floatBorder}ff";
        };
      };

      services.mako = {
        enable = true;
        settings = {
          font = "JetBrains Mono 10";
          default-timeout = 5000;
          border-radius = 4;
        };
      };

      # Answers privilege prompts from GUI programs.
      services.polkit-gnome.enable = true;
    };
}
