# sesh builds with Go 1.27 and runs mockery in its preBuild phase. The vendored
# x/tools of mockery cannot read the export data of Go 1.27 ("export data
# version 5 is greater than maximum supported version 4"). Thus, the checks of
# mockery fail, and the sesh build also fails. Build both packages with Go 1.26
# until nixpkgs fixes this problem. Remove this overlay when
# `nix build nixpkgs#sesh` succeeds again.
final: prev: {
  sesh = prev.sesh.override { buildGo127Module = final.buildGo126Module; };
}
