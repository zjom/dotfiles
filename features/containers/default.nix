# Podman on each NixOS host. Containers run rootless as the user. `docker` is an
# alias of `podman`, so tools that call `docker` also work.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      virtualisation.containers = {
        enable = true;
        # Short names like `hello-world` resolve on Docker Hub, as in Docker.
        registries.search = [ "docker.io" ];
      };
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        # Containers on one compose network can find each other by name.
        defaultNetwork.settings.dns_enabled = true;
      };

      environment.systemPackages = [ pkgs.podman-compose ];
    };
}
