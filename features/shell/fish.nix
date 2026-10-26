{ leaf, ... }:
{
  nodes.fish = leaf "fish" (
    { config, lib, ... }:
    {
      # fish starts without --no-config, because that flag also skips
      # /etc/fish/config.fish and turns on private mode. The configuration of
      # this node runs from --init-command, after ~/.config/fish. Thus,
      # ~/.config/fish must stay empty.
      wrappers.fish = {
        flags."--no-config" = false;

        shellAliases = {
          c = "clear";
          clean = "sudo nix-collect-garbage -d";
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

          # The checkout of this repository. Functions that need the checkout
          # read this variable.
          set -q DOTFILES; or set -gx DOTFILES ~/${config.settings.flakeDir}
        '';
      };
    }
  );
}
