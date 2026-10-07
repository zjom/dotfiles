# `nh os switch` / `nh darwin switch` in place of the *-rebuild commands:
# elevates on its own, and shows a diff of what changed. `rebuild` runs it
# against this flake on every host.
{
  homeManager.base =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      platform = if pkgs.stdenv.hostPlatform.isDarwin then "darwin" else "os";
    in
    {
      programs.nh = {
        enable = true;
        flake = config.my.flakeRoot;
      };

      # The configuration is named outright: nh would otherwise go by the
      # machine's hostname, which under WSL is "nixos" rather than "wsl".
      programs.fish.shellAliases.rebuild = "nh ${platform} switch ${config.my.flakeRoot} -H ${osConfig.my.hostName}";
    };
}
