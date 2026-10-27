{ leaf, ... }:
{
  nodes.waybar = leaf "waybar" (
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.settings) colors;

      # TradingView symbols, as EXCHANGE:SYMBOL. The bar shows the part after
      # the exchange.
      tickers = [
        "OANDA:XAUUSD"
        "ASX:GOLD"
        "TVC:US10Y"
        "OANDA:XAGUSD"
        "CRYPTO:BTCUSD"
        "AMEX:SPY"
      ];

      # Fetches all tickers every 5 minutes and prints one ticker per line as
      # waybar JSON. Each ticker shows once per fetch, for the refresh time
      # divided by the number of tickers. The tooltip lists all tickers. A
      # ticker whose fetch fails keeps its last price with the stale class. A delayed quote
      # shows its delay, such as (15m). The shown symbol is in $current, for
      # waybar-tickers-open.
      #
      # The TradingView session cookies in the trading_view secret give the
      # real-time data of the account. The script reads them at each fetch and
      # gives them to curl on stdin, so they are not in its arguments. Without
      # them, the quotes are the delayed data of a guest.
      waybar-tickers = pkgs.writeShellApplication {
        name = "waybar-tickers";
        runtimeInputs = with pkgs; [
          coreutils
          curl
          jq
          sops
        ];
        text = ''
          export LC_ALL=C
          refresh=300
          rotate=$(( refresh / ($# > 0 ? $# : 1) ))
          secrets="$HOME/${config.settings.flakeDir}/secrets/secrets.yaml"
          current="''${XDG_RUNTIME_DIR:?}/waybar-tickers"
          declare -A text class
          last_fetch=0

          # Prints a curl config with the cookie header, or nothing if the
          # secret cannot be decrypted.
          cookies() {
            local id sign
            if id=$(sops -d --extract '["trading_view"]["sessionid"]' "$secrets" 2>/dev/null) &&
              sign=$(sops -d --extract '["trading_view"]["sessionid_sign"]' "$secrets" 2>/dev/null); then
              printf 'cookie = "sessionid=%s; sessionid_sign=%s"\n' "$id" "$sign"
            fi
          }

          fetch() {
            local config symbol label quote price pct mode arrow delay
            config=$(cookies)
            for symbol in "$@"; do
              label=''${symbol#*:}
              if quote=$(curl -fsS --max-time 10 -A 'Mozilla/5.0' -K - -G \
                --data-urlencode "symbol=$symbol" --data-urlencode 'fields=close,change,update_mode' \
                https://scanner.tradingview.com/symbol <<<"$config" |
                jq -er 'select(.close != null) | "\(.close) \(.change // 0) \(.update_mode)"'); then
                read -r price pct mode <<<"$quote"
                if [[ $pct == -* ]]; then class[$symbol]=down; arrow=▼; else class[$symbol]=up; arrow=▲; fi
                delay=""
                if [[ $mode =~ ^delayed_streaming_([0-9]+)$ ]]; then
                  delay=" ($(( BASH_REMATCH[1] / 60 ))m)"
                fi
                text[$symbol]=$(printf '%s %.2f %s%.2f%%%s' "$label" "$price" "$arrow" "''${pct#-}" "$delay")
              elif [[ -n ''${text[$symbol]:-} ]]; then
                class[$symbol]=stale
              fi
            done
          }

          i=0
          while true; do
            now=$(date +%s)
            if (( now - last_fetch >= refresh )); then
              fetch "$@"
              last_fetch=$now
            fi
            shown=()
            for symbol in "$@"; do
              [[ -n ''${text[$symbol]:-} ]] && shown+=("$symbol")
            done
            if (( ''${#shown[@]} == 0 )); then
              echo '{"text":""}'
            else
              symbol=''${shown[i % ''${#shown[@]}]}
              echo "$symbol" >"$current"
              tooltip=$(for s in "''${shown[@]}"; do echo "''${text[$s]}"; done)
              jq -cn --arg text "''${text[$symbol]}" --arg class "''${class[$symbol]}" \
                --arg tooltip "$tooltip" '{$text, $class, $tooltip}'
            fi
            i=$(( i + 1 ))
            sleep "$rotate"
          done
        '';
      };

      # Opens the TradingView chart of the symbol that waybar-tickers shows.
      waybar-tickers-open = pkgs.writeShellApplication {
        name = "waybar-tickers-open";
        runtimeInputs = with pkgs; [
          coreutils
          xdg-utils
        ];
        text = ''
          symbol=$(cat "''${XDG_RUNTIME_DIR:?}/waybar-tickers")
          xdg-open "https://www.tradingview.com/chart/?symbol=$symbol"
        '';
      };
    in
    {
      wrappers.waybar = {
        settings = {
          layer = "top";
          position = "top";
          height = 26;
          modules-left = [ "niri/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "custom/tickers"
            "mpris"
            "tray"
            "network"
            "bluetooth"
            "pulseaudio"
            "battery"
          ];
          clock.format = "{:%a %d %b  %H:%M}";
          network = {
            format-wifi = "{essid}";
            format-ethernet = "wired";
            format-disconnected = "offline";
          };
          bluetooth = {
            format = "bt";
            format-off = "bt off";
            format-disabled = "bt off";
            format-connected = "bt {num_connections}";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}";
            tooltip-format-enumerate-connected-battery = "{device_alias} {device_battery_percentage}%";
          };
          pulseaudio = {
            format = "vol {volume}%";
            format-muted = "muted";
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          battery = {
            format = "bat {capacity}%";
            format-charging = "chg {capacity}%";
            states.warning = 20;
          };
          mpris = {
            format = "{status_icon} {dynamic}";
            format-paused = "{status_icon} {dynamic}";
            format-stopped = "";
            dynamic-order = [
              "artist"
              "title"
            ];
            dynamic-separator = " - ";
            dynamic-len = 45;
            status-icons = {
              playing = "▶";
              paused = "⏸";
            };
            tooltip-format = "{title}\n{artist}\n{album}\n{position} / {length}";
            interval = 1;
          };
          "custom/tickers" = {
            exec = lib.escapeShellArgs ([ (lib.getExe waybar-tickers) ] ++ tickers);
            return-type = "json";
            on-click = lib.getExe waybar-tickers-open;
          };
          tray.spacing = 8;
        };

        # This value is a path because the module builds its default style file
        # from the wrong option.
        "style.css".path = pkgs.writeText "waybar-style.css" (
          with colors;
          ''
            * {
              font-family: "JetBrains Mono", "Symbols Nerd Font";
              font-size: 12px;
              min-height: 0;
            }
            window#waybar {
              background: #${bg};
              color: #${fg};
              border-bottom: 1px solid #${line};
            }
            #workspaces button {
              padding: 0 6px;
              color: #${comment};
              border-radius: 0;
            }
            #workspaces button:hover {
              background: #${line};
              box-shadow: none;
              text-shadow: none;
            }
            #workspaces button.active {
              color: #${fg};
              box-shadow: inset 0 -2px #${keyword};
            }
            #workspaces button.urgent {
              color: #${error};
            }
            tooltip {
              background: #${inactiveBg};
              border: 1px solid #${floatBorder};
            }
            tooltip label {
              color: #${fg};
            }
            #clock, #custom-tickers, #mpris, #tray, #network, #bluetooth, #pulseaudio, #battery {
              padding: 0 10px;
            }
            #network.disconnected, #bluetooth.off, #bluetooth.disabled, #pulseaudio.muted {
              color: #${comment};
            }
            #mpris.paused {
              color: #${comment};
            }
            #custom-tickers.up {
              color: #${plus};
            }
            #custom-tickers.down {
              color: #${error};
            }
            #custom-tickers.stale {
              color: #${comment};
            }
            #battery.charging {
              color: #${plus};
            }
            #battery.warning:not(.charging) {
              color: #${error};
            }
          ''
        );
      };
    }
  );

  # niri-session starts graphical-session.target, which starts the bar.
  flake.modules.homeManager.desktop =
    { osConfig, ... }:
    {
      programs.waybar = {
        enable = true;
        package = osConfig.wrappers.waybar.wrapper;
        systemd.enable = true;
      };
    };
}
