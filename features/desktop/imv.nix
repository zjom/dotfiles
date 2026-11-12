{ leaf, ... }:
{
  # imv draws transparent pixels on black, which hides black artwork such as
  # logos in SVG. A checkerboard shows the transparent area.
  nodes.imv = leaf "imv" {
    wrappers.imv.settings.options.background = "checks";
  };
}
