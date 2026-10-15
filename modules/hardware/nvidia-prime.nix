# Hardware node (NixOS): an NVIDIA GPU next to an integrated GPU that drives the
# panel (PRIME offload). The integrated GPU renders the desktop. The NVIDIA GPU
# stays powered off until you start a program on the NVIDIA GPU with
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
        # For Turing GPUs and later GPUs, NVIDIA recommends the open kernel
        # module.
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
