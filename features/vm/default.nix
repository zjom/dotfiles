# quickemu and quickgui for desktop VMs. Make a VM with quickget, for example:
#
#   cd ~/vms && quickget windows 11 && quickemu --vm windows-11.conf
#
# Keep the VMs outside this repository. A flake that evaluates from a path
# cannot copy the socket files that quickemu puts next to a running VM.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      # quickget downloads the Windows VirtIO drivers from fedorapeople.org. A
      # bot check now protects that site, so curl gets an HTML page in place of
      # the ISO. Then the Windows installer has no driver for the virtio disk and
      # shows no disks. This patch copies the ISO from the virtio-win package of
      # nixpkgs, which cache.nixos.org has.
      quickemu = pkgs.quickemu.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace quickget --replace-fail \
            'web_get "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" "''${VM_PATH}"' \
            'install -m 644 ${pkgs.virtio-win.src} "''${VM_PATH}/virtio-win.iso"'
        '';
      });
    in
    {
      environment.systemPackages = [
        quickemu
        (pkgs.quickgui.override { inherit quickemu; })
      ];
    };
}
