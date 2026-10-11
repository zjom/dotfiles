{
  description = "tldraw offline (official AppImage)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      version = "1.21.0";
      sources = {
        x86_64-linux = {
          arch = "x86_64";
          hash = "sha256-FpPZLRdQLG+3pFg5snxI/yQE7LGs0XxvPbKfXaPBEZs=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-amtkpOMPK/Q1/AUJLnZ1lwC4hH+Nc39B1cXNnJ5MCAY=";
        };
      };
      forAll =
        f:
        nixpkgs.lib.genAttrs (builtins.attrNames sources) (
          system: f system nixpkgs.legacyPackages.${system}
        );

      mkTldraw =
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          pname = "tldraw-offline";
          src = pkgs.fetchurl {
            url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-${sources.${system}.arch}.AppImage";
            inherit (sources.${system}) hash;
          };
          contents = pkgs.appimageTools.extract { inherit pname version src; };
        in
        pkgs.appimageTools.wrapType2 {
          inherit pname version src;

          # Install the .desktop entry and icons that ship inside the AppImage
          extraInstallCommands = ''
            desktop=$(find ${contents} -maxdepth 1 -name '*.desktop' | head -n1)
            install -Dm444 "$desktop" $out/share/applications/${pname}.desktop
            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace-quiet 'Exec=AppRun --no-sandbox' 'Exec=${pname}' \
              --replace-quiet 'Exec=AppRun' 'Exec=${pname}'
            if [ -d ${contents}/usr/share/icons ]; then
              cp -r ${contents}/usr/share/icons $out/share/
            fi
          '';

          meta = {
            description = "Local tldraw whiteboard for files and agents";
            homepage = "https://offline.tldraw.com";
            license = pkgs.lib.licenses.unfree;
            platforms = builtins.attrNames sources;
            mainProgram = pname;
          };
        };
    in
    {
      packages = forAll (system: pkgs: { default = mkTldraw pkgs; });

      # Builds with the consumer's pkgs, so its `allowUnfree` applies.
      overlays.default = final: prev: { tldraw-offline = mkTldraw final; };
    };
}
