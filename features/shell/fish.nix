# Leaf node: fish. This node configures only the behaviour of fish itself. Each
# function, alias and bind that calls another configured program is in a
# composite.
{ leaf, ... }:
{
  nodes.fish = leaf "fish" (
    { lib, ... }:
    {
      # fish starts without --no-config (decision D22). That flag also skips
      # the startup files of fish itself and /etc/fish/config.fish, and it
      # turns on private mode. The configuration of this node runs from
      # --init-command, after all configuration files, so it overrides
      # ~/.config/fish. That directory must stay empty.
      wrappers.fish = {
        flags."--no-config" = false;

        # These commands are not configured programs of this graph (decision
        # D17), so these commands belong to fish itself.
        shellAliases = {
          c = "clear";
          clean = "sudo nix-collect-garbage -d";
          oc = "opencode";
          q = "exit";
          tt = "touch";
        };

        # Before the glue of the composites, independent of the import order.
        configFile.content = lib.mkBefore ''
          # Programs that language toolchains install outside Nix.
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
              # Make the title lowercase, replace each run of non-alphanumeric
              # characters with one hyphen, and remove hyphens at the start and
              # at the end.
              set -l slug (string lower -- $title | string replace -ra '[^a-z0-9]+' '-' | string trim -c '-')

              nb a "$d-$slug.md" -t "$d - $title"
          end
        '';
      };
    }
  );
}
