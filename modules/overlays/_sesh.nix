# sesh builds with Go 1.27 and runs mockery in its preBuild, but mockery's
# vendored x/tools can't read Go 1.27 export data ("export data version 5 is
# greater than maximum supported version 4"), so mockery fails its own
# checks and sesh with it. Build both with Go 1.26 until nixpkgs catches up;
# drop this once `nix build nixpkgs#sesh` succeeds again.
final: prev: {
  sesh = prev.sesh.override { buildGo127Module = final.buildGo126Module; };
}
