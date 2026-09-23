# Track claude-code ahead of nixpkgs.
#
# The nixpkgs derivation reads its version and its per-platform checksums out
# of a manifest.zst.json that Anthropic publishes alongside each release, and
# takes that manifest as an argument, so a newer release needs no new
# derivation -- only a newer manifest. The file next to this one is vendored
# rather than fetched so the build stays pure and pinned; refresh it with
#
#   curl -fsSL https://downloads.claude.ai/claude-code-releases/latest
#   curl -fsSL https://downloads.claude.ai/claude-code-releases/<version>/manifest.zst.json \
#     -o overlays/claude-code/manifest.zst.json
#
# and drop this overlay once nixpkgs has caught up.
final: prev:

let
  manifest = final.lib.importJSON ./manifest.zst.json;
in
{
  claude-code =
    if final.lib.versionOlder prev.claude-code.version manifest.version then
      prev.claude-code.override { inherit manifest; }
    else
      prev.claude-code;
}
