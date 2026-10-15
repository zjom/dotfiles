# The bare metal NixOS machine, a Lenovo LOQ 15IRH8: Intel Raptor Lake
# graphics driving the panel, an RTX 4050 beside it.
{ config, inputs, ... }:

let
  inherit (config.flake.modules) nixos;
  inherit (config) nodes;
in
{
  flake.nixosConfigurations.loq = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixos.base
      nixos.desktop
      nixos.intel-cpu
      nixos.laptop
      nixos.audio
      nixos.nvidia-prime
      nodes.env
      inputs.openlogi.nixosModules.default

      # Generated on the machine by `nixos-generate-config`; see the README.
      ./_hardware-configuration.nix

      (
        { config, pkgs, ... }:
        let
          zen-draw = inputs.zen-draw.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          my.username = "zi";
          my.hostName = "loq";

          environment.systemPackages = with pkgs; [
            anki
            aseprite
            obs-studio
            zen-draw
          ];

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.kernelPackages = pkgs.linuxPackages_latest;

          networking.hostName = "loq";
          networking.networkmanager.enable = true;

          # Join the tailnet once with `sudo tailscale up` after the first switch.
          services.tailscale = {
            enable = true;
            openFirewall = true;
            # Loosens reverse path filtering so advertised subnet routes work.
            useRoutingFeatures = "client";
            # Applied with `tailscale set` on every boot; extraUpFlags would only
            # take effect alongside an authKeyFile.
            extraSetFlags = [
              "--operator=${config.my.username}"
              "--accept-routes"
            ];
          };

          # SSH is reachable over the tailnet only; the port stays closed on
          # every other interface.
          services.openssh = {
            enable = true;
            openFirewall = false;
            settings.PermitRootLogin = "no";
          };
          networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ 22 ];

          i18n.defaultLocale = "en_GB.UTF-8";
          i18n.extraLocaleSettings = {
            LC_ADDRESS = "en_AU.UTF-8";
            LC_IDENTIFICATION = "en_AU.UTF-8";
            LC_MEASUREMENT = "en_AU.UTF-8";
            LC_MONETARY = "en_AU.UTF-8";
            LC_NAME = "en_AU.UTF-8";
            LC_NUMERIC = "en_AU.UTF-8";
            LC_PAPER = "en_AU.UTF-8";
            LC_TELEPHONE = "en_AU.UTF-8";
            LC_TIME = "en_AU.UTF-8";
          };

          services.xserver.xkb = {
            layout = "us";
            options = "ctrl:nocaps";
          };
          console.useXkbConfig = true;

          # Set a password with `passwd` after the first boot.
          users.users.${config.my.username} = {
            isNormalUser = true;
            description = "Zihan Jin";
            extraGroups = [
              "wheel"
              "networkmanager"
              "video"
            ];
          };

          # From /sys/class/drm/card*/device: 0000:00:02.0 and 0000:01:00.0.
          hardware.nvidia.prime = {
            intelBusId = "PCI:0@0:2:0";
            nvidiaBusId = "PCI:1@0:0:0";
          };

          programs.firefox.enable = true;

          # The NixOS release whose defaults this system's stateful data was created
          # against. Set it to the release of the first install, the value
          # `nixos-generate-config` writes into its configuration.nix, and leave it.
          system.stateVersion = "26.05";
        }
      )
    ];
  };
}
