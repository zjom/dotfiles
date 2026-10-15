# Leaf node: fish. Only fish's own behaviour; every function, alias and bind
# that calls another configured program lives in a composite.
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

      # The upstream module passes --no-config, so ~/.config/fish is ignored.
      # Universal variables (`set -U`) still persist in fish's data directory.
      wrappers.fish = {
        enable = true;

        # Commands that are not configured programs of this graph (decision
        # D17), so they belong to fish itself.
        shellAliases = {
          c = "clear";
          clean = "sudo nix-collect-garbage -d";
          oc = "opencode";
          q = "exit";
          tt = "touch";
        };

        configFile.content = ''
          # Programs installed outside Nix, by language toolchains.
          fish_add_path --global --path ~/.local/bin ~/go/bin ~/.cargo/bin

          if status is-interactive
              set -g fish_greeting
              set -g fish_key_bindings fish_vi_key_bindings
          end

          function nn --description "New nb note, named after today's date and its title"
              if test (count $argv) -eq 0
                  echo "usage: nn <note title>" >&2
                  return 1
              end

              set -l title (string join ' ' -- $argv)
              set -l d (date +%y%m%d)
              # lowercase, collapse anything non-alphanumeric into single hyphens, trim stray hyphens
              set -l slug (string lower -- $title | string replace -ra '[^a-z0-9]+' '-' | string trim -c '-')

              nb a "$d-$slug.md" -t "$d - $title"
          end
        '';
      };
    };
}
