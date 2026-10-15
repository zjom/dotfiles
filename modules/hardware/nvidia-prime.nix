# Hardware node (NixOS): an NVIDIA GPU beside an integrated one that drives
# the panel (PRIME offload). The integrated GPU renders the desktop; the NVIDIA
# GPU stays powered down until something is started on it with
# `nvidia-offload <program>`. The host sets the two bus IDs
# (hardware.nvidia.prime.{intel,amdgpu,nvidia}BusId).
{
  flake.modules.nixos.nvidia-prime =
    { lib, ... }:
    {
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = lib.mkDefault true;
      services.xserver.videoDrivers = [
        "modesetting"
        "nvidia"
      ];
      hardware.nvidia = {
        # The open kernel module is the recommended one from Turing on.
        open = lib.mkDefault true;
        modesetting.enable = true;
        powerManagement.enable = lib.mkDefault true;
        powerManagement.finegrained = lib.mkDefault true;
        prime = {
          offload.enable = true;
          offload.enableOffloadCmd = lib.mkDefault true;
        };
      };
    };
}
