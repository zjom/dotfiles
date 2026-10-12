# Every executable under ../../scripts, at any depth, symlinked by name into
# $XDG_BIN_HOME. The flake cannot see that directory, so the links are made on
# the machine: on each switch, and on Linux again whenever something under it
# changes, so adding, removing or chmod +x-ing a script needs no switch.
{
  homeManager.base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      src = "${config.my.dotfilesRoot}/scripts";
      bin = config.xdg.binHome;

      link-scripts = pkgs.writeShellApplication {
        name = "link-scripts";
        runtimeInputs = [ pkgs.findutils ];
        text = ''
          src=${lib.escapeShellArg src}
          bin=${lib.escapeShellArg bin}
          mkdir -p "$bin"

          # Links of ours whose script is gone or no longer executable.
          for link in "$bin"/*; do
            [[ -L $link ]] || continue
            target=$(readlink "$link")
            [[ $target == "$src"/* ]] || continue
            [[ -f $target && -x $target ]] || rm -- "$link"
          done

          [[ -d $src ]] || exit 0
          # Dot directories are skipped; anything already in $bin that is not
          # one of these links is left alone.
          find "$src" -name '.*' -prune -o -type f -perm -u+x -print0 |
            while IFS= read -r -d "" script; do
              link=$bin/$(basename "$script")
              if [[ -e $link || -L $link ]] && [[ $(readlink "$link") != "$src"/* ]]; then
                echo "link-scripts: $link exists, not linking $script" >&2
                continue
              fi
              ln -sfn "$script" "$link"
            done
        '';
      };
    in
    {
      home.activation.linkScripts = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run ${lib.getExe link-scripts}
      '';

      systemd.user.services.link-scripts = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        Unit.Description = "Link ${src} into ${bin} as it changes";
        Service = {
          ExecStart = toString (
            pkgs.writeShellScript "watch-scripts" ''
              ${lib.getExe link-scripts}
              ${pkgs.inotify-tools}/bin/inotifywait -mrq \
                -e create,delete,move,attrib,close_write --format x ${lib.escapeShellArg src} |
                while read -r _; do ${lib.getExe link-scripts}; done
            ''
          );
          # The directory may not exist yet on a fresh checkout.
          Restart = "on-failure";
          RestartSec = 30;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
