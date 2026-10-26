# Hardware module (NixOS): sound through PipeWire, with the compatibility layers
# for PulseAudio and ALSA.
{
  flake.modules.nixos.audio =
    { lib, ... }:
    {
      services.pulseaudio.enable = false;
      security.rtkit.enable = lib.mkDefault true;
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        alsa.support32Bit = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
    };
}
