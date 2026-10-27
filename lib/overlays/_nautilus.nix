# The en_GB translation of Nautilus names the trash "Wastebasket". Nautilus
# uses its untranslated strings (US English, "Trash") when LANGUAGE names a
# locale without a translation. The other programs keep en_GB. Override the
# package itself, because niri starts pkgs.nautilus as a D-Bus service.
final: prev: {
  nautilus = prev.nautilus.overrideAttrs (old: {
    preFixup = (old.preFixup or "") + ''
      gappsWrapperArgs+=(--set LANGUAGE en_US)
    '';
  });
}
