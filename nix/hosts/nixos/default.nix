# System level configuration for the WSL machine.
{
  config,
  inputs,
  username,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    ../../modules/system/common.nix
    ../../modules/system/nixos.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = username;

  # GPU. WSL hands the host GPU over as /dev/dxg rather than as a DRM node, so
  # hardware OpenGL comes from Mesa's d3d12 Gallium driver driving the Windows
  # user mode driver, which this option symlinks into the store and onto
  # /run/opengl-driver. Two things then still have to be said out loud, or
  # everything silently lands on llvmpipe instead.
  wsl.useWindowsDriver = true;

  environment.sessionVariables = {
    # With no DRM node to probe, the Mesa loader has nothing to infer a driver
    # from and settles for software rendering, so name the driver outright.
    GALLIUM_DRIVER = "d3d12";

    # d3d12 reaches the Windows driver by dlopen'ing "libdxcore.so" under its
    # bare name, and nothing puts that directory on the linker's search path.
    LD_LIBRARY_PATH = [ "${config.wsl.wslLib}/lib" ];

    # Both the integrated and the discrete adapter answer; prefer the latter.
    MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
  };

  # The NixOS release whose defaults this system's stateful data was created
  # against. Leave it at the release of the first install; read the manual
  # before changing it.
  system.stateVersion = "26.05";
}
