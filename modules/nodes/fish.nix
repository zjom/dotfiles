# Leaf node: fish. This node configures only the behaviour of fish itself. Each
# function, alias and bind that calls another configured program is in a
# composite.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.fish =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "fish";
          value = wlib.wrapperModules.fish;
        })
      ];

      entry = lib.mkDefault "fish";

      # The upstream module passes --no-config, so fish ignores ~/.config/fish.
      # Universal variables (`set -U`) still persist in the data directory of
      # fish.
      wrappers.fish = {
        enable = true;

        # These commands are not configured programs of this graph (decision
        # D17), so these commands belong to fish itself.
        shellAliases = {
          c = "clear";
          clean = "sudo nix-collect-garbage -d";
          oc = "opencode";
          q = "exit";
          tt = "touch";
        };

        configFile.content = ''
          # Programs that language toolchains install outside Nix.
          fish_add_path --global --path ~/.local/bin ~/go/bin ~/.cargo/bin

          if status is-interactive
              set -g fish_greeting
              set -g fish_key_bindings fish_vi_key_bindings

              # --no-config also skips the config.fish of fish itself, which
              # starts the interactive setup at the first prompt. Without that
              # setup, fish never loads $fish_key_bindings (decision D23).
              if not functions -q __fish_on_interactive
                  function __fish_on_interactive --on-event fish_prompt --on-event fish_read
                      functions -e __fish_on_interactive
                      __fish_config_interactive
                  end
              end
          end

          function nn --description "New nb note, named after today's date and its title"
              if test (count $argv) -eq 0
                  echo "usage: nn <note title>" >&2
                  return 1
              end

              set -l title (string join ' ' -- $argv)
              set -l d (date +%y%m%d)
              # Make the title lowercase, replace each run of non-alphanumeric
              # characters with one hyphen, and remove hyphens at the start and
              # at the end.
              set -l slug (string lower -- $title | string replace -ra '[^a-z0-9]+' '-' | string trim -c '-')

              nb a "$d-$slug.md" -t "$d - $title"
          end
        '';
      };
    };
}
