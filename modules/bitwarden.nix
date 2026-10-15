# Bitwarden on every host: `bw` for the password vault and `bws` for Secrets
# Manager. Neither token lives in this repo or the Nix store -- both are kept
# in the OS keyring (GNOME Keyring on Linux, the login Keychain on macOS) and
# the wrappers below hand them to the CLI only for the duration of a call.
#
# bws needs its machine-account access token stored once per machine:
#
#   secret-tool store --label="Bitwarden Secrets Manager" service bws   # Linux
#   security add-generic-password -a $USER -s bws -w                    # macOS
#
# bw needs `bw login` once per machine. After that the first `bw` call of a
# login session asks for the master password, and the resulting session key is
# kept in the keyring so every other shell reuses it until `bw lock`.
{
  homeManager.base =
    { lib, pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;

      lookup =
        service:
        if isDarwin then
          "security find-generic-password -a $USER -s ${service} -w 2>/dev/null"
        else
          "secret-tool lookup service ${service} 2>/dev/null";

      # The macOS `security` tool only takes the secret as an argument, so the
      # session key is briefly visible in the process list there.
      store =
        service: value:
        if isDarwin then
          "security add-generic-password -U -a $USER -s ${service} -w ${value}"
        else
          "printf %s ${value} | secret-tool store --label='Bitwarden CLI session' service ${service}";
    in
    {
      home.packages = [
        pkgs.bitwarden-cli
        pkgs.bws
      ]
      ++ lib.optional (!isDarwin) pkgs.libsecret;

      programs.fish.functions = {
        bws = {
          description = "bws, with its access token from the keyring";
          wraps = "bws";
          body = ''
            set -lx BWS_ACCESS_TOKEN (${lookup "bws"})
            or begin
                echo "bws: no access token in the keyring, see modules/bitwarden.nix" >&2
                return 1
            end
            command bws $argv
          '';
        };

        bw = {
          description = "bw, unlocking once per login session";
          wraps = "bw";
          body = ''
            set -q BW_SESSION; or set -gx BW_SESSION (${lookup "bw-session"})
            if not command bw unlock --check &>/dev/null
                set -gx BW_SESSION (command bw unlock --raw); or return 1
                ${store "bw-session" "$BW_SESSION"}
            end
            command bw $argv
          '';
        };
      };
    };
}
