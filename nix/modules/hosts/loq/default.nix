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

      # Generated on the machine by `nixos-generate-config`; see the README.
      ./_hardware-configuration.nix

      (
        { config, pkgs, ... }:
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          my.username = "zi";
          my.hostName = "loq";

          home-manager.sharedModules = [
            {
              home.packages = with pkgs; [
                anki
                aseprite
              ];
            }
          ];

            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            boot.kernelPackages = pkgs.linuxPackages_latest;

            networking.hostName = "loq";
            networking.networkmanager.enable = true;

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

            # Under WSL, NixOS-WSL declares the user; here nothing else does. Set a
            # password with `passwd` after the first boot.
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

            # The NixOS release whose defaults this system's stateful data was created
            # against. Set it to the release of the first install, the value
            # `nixos-generate-config` writes into its configuration.nix, and leave it.
            system.stateVersion = "26.05";
        }
      )
    ];
  };
}
