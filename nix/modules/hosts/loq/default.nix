# The bare metal NixOS machine, a Lenovo LOQ 15IRH8: Intel Raptor Lake
# graphics driving the panel, an RTX 4050 beside it.
{ config, inputs, ... }:

let
  inherit (config) nixos;
in
{
  flake.nixosConfigurations.loq = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixos.base
      nixos.desktop
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

          home-manager.sharedModules = [
            {
              home.packages = with pkgs; [
                anki
                aseprite
                obs-studio
                zen-draw
              ];
            }
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

          # Graphics. The panel hangs off the Intel GPU, which renders the desktop.
          # The NVIDIA GPU stays powered down until something is started on it with
          # `nvidia-offload <program>`.
          hardware.graphics.enable = true;
          hardware.graphics.enable32Bit = true;
          services.xserver.videoDrivers = [
            "modesetting"
            "nvidia"
          ];
          hardware.nvidia = {
            # The open kernel module is the recommended one from Turing on.
            open = true;
            modesetting.enable = true;
            powerManagement.enable = true;
            powerManagement.finegrained = true;
            prime = {
              offload.enable = true;
              offload.enableOffloadCmd = true;
              # From /sys/class/drm/card*/device: 0000:00:02.0 and 0000:01:00.0.
              intelBusId = "PCI:0@0:2:0";
              nvidiaBusId = "PCI:1@0:0:0";
            };
          };

          hardware.enableRedistributableFirmware = true;
          hardware.bluetooth.enable = true;
          services.power-profiles-daemon.enable = true;
          services.upower.enable = true;

          services.pulseaudio.enable = false;
          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

          programs.firefox.enable = true;

          # Logitech mice and keyboards. The module also installs the udev rules
          # for hidraw/uinput access and starts openlogi-agent with the session.
          programs.openlogi = {
            enable = true;
            launchAtLogin = true;
            # Upstream only adds GPUI's dlopen'd graphics libraries to openlogi-desktop's RUNPATH; without them openlogi-overlay panics with NoWaylandLib. See https://github.com/AprilNEA/OpenLogi/pull/785
            package = inputs.openlogi.packages.${pkgs.stdenv.hostPlatform.system}.openlogi.overrideAttrs (old: {
              postFixup = (old.postFixup or "") + ''
                patchelf --add-rpath "${
                  pkgs.lib.makeLibraryPath [
                    pkgs.libGL
                    pkgs.wayland
                    pkgs.vulkan-loader
                  ]
                }" "$out/bin/openlogi-overlay"
              '';
            });
          };

          # The NixOS release whose defaults this system's stateful data was created
          # against. Set it to the release of the first install, the value
          # `nixos-generate-config` writes into its configuration.nix, and leave it.
          system.stateVersion = "26.05";
        }
      )
    ];
  };
}
