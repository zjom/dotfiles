# The bare metal NixOS machine, a Lenovo LOQ 15IRH8. Intel Raptor Lake graphics
# drive the panel. An RTX 4050 is the second GPU.
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
      nixos.mx-master-3
      nodes.env

      # `nixos-generate-config` generates this file on the machine. See
      # README.md.
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

          # After the first switch, join the tailnet one time with
          # `sudo tailscale up`.
          services.tailscale = {
            enable = true;
            openFirewall = true;
            # Makes the reverse path filter less strict, so advertised subnet
            # routes work.
            useRoutingFeatures = "client";
            # `tailscale set` applies these flags on each boot. extraUpFlags
            # applies only together with an authKeyFile.
            extraSetFlags = [
              "--operator=${config.my.username}"
              "--accept-routes"
            ];
          };

          # SSH is available only through the tailnet. The port stays closed on
          # all other interfaces.
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

          # After the first boot, set a password with `passwd`.
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

          # The NixOS release that created the stateful data of this system. Set
          # this value to the release of the first installation.
          # `nixos-generate-config` writes this value into its
          # configuration.nix. Do not change this value after that.
          system.stateVersion = "26.05";

          # The Home Manager release of the first activation on this host. Do
          # not change this value after that.
          home-manager.users.${config.my.username}.home.stateVersion = "26.05";
        }
      )
    ];
  };
}
