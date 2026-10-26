# The WSL machine. All WSL-specific configuration, including the GPU
# passthrough, is in this file.
top@{ inputs, ... }:

{
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      top.config.flake.modules.nixos.base
      top.config.nodes.env
      inputs.nixos-wsl.nixosModules.wsl

      (
        { config, ... }:
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          my.username = "zi";
          my.hostName = "wsl";

          wsl.enable = true;
          wsl.defaultUser = config.my.username;

          # GPU. WSL gives the host GPU to Linux as /dev/dxg, not as a DRM node.
          # Thus, hardware OpenGL comes from the d3d12 Gallium driver of Mesa.
          # This driver uses the Windows user-mode driver. This option links the
          # Windows user-mode driver into the store and into /run/opengl-driver.
          # Two more settings are necessary. Without these settings, all
          # rendering uses llvmpipe, and no error appears.
          wsl.useWindowsDriver = true;
          hardware.graphics.enable = true;
          environment.sessionVariables = {
            # There is no DRM node, so the Mesa loader cannot detect a driver.
            # The loader then uses software rendering. Thus, this setting names
            # the driver explicitly.
            GALLIUM_DRIVER = "d3d12";

            # d3d12 uses dlopen to load "libdxcore.so" by its plain name. No
            # setting puts the directory of that library on the search path of
            # the linker.
            LD_LIBRARY_PATH = [ "${config.wsl.wslLib}/lib" ];

            # The integrated adapter and the discrete adapter both respond. Use
            # the discrete adapter.
            MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
          };

          # The NixOS release that created the stateful data of this system.
          # Keep the release of the first installation. Read the manual before
          # you change this value.
          system.stateVersion = "26.05";

          # The Home Manager release of the first activation on this host. Do
          # not change this value after that.
          home-manager.users.${config.my.username}.home.stateVersion = "26.05";
        }
      )
    ];
  };
}
