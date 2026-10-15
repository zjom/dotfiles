# Composite node: `bw` and `bws` in fish, with their secrets kept in the OS
# keyring (GNOME Keyring on Linux, the login Keychain on macOS) and handed to
# the CLI only for the duration of a call. Neither token lives in this repo or
# the Nix store.
#
# bws needs its machine-account access token stored once per machine:
#
#   secret-tool store --label="Bitwarden Secrets Manager" service bws   # Linux
#   security add-generic-password -a $USER -s bws -w                    # macOS
#
# bw needs `bw login` once per machine. After that the first `bw` call of a
# login session asks for the master password, and the resulting session key is
# kept in the keyring so every other shell reuses it until `bw lock`.
{ config, ... }:
{
  nodes.bitwarden =
    { lib, pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
      secret-tool = lib.getExe' pkgs.libsecret "secret-tool";

      lookup =
        service:
        if isDarwin then
          "security find-generic-password -a $USER -s ${service} -w 2>/dev/null"
        else
          "${secret-tool} lookup service ${service} 2>/dev/null";

      # The macOS `security` tool only takes the secret as an argument, so the
      # session key is briefly visible in the process list there.
      store =
        service: value:
        if isDarwin then
          "security add-generic-password -U -a $USER -s ${service} -w ${value}"
        else
          "printf %s ${value} | ${secret-tool} store --label='Bitwarden CLI session' service ${service}";
    in
    {
      imports = with config.nodes; [
        fish
        bw
        bws
      ];

      entry = "fish";

      wrappers.fish.configFile.content = ''
        function bws --wraps bws --description "bws, with its access token from the keyring"
            set -lx BWS_ACCESS_TOKEN (${lookup "bws"})
            or begin
                echo "bws: no access token in the keyring, see modules/nodes/bitwarden.nix" >&2
                return 1
            end
            command bws $argv
        end

        function bw --wraps bw --description "bw, unlocking once per login session"
            set -q BW_SESSION; or set -gx BW_SESSION (${lookup "bw-session"})
            if not command bw unlock --check &>/dev/null
                set -gx BW_SESSION (command bw unlock --raw); or return 1
                ${store "bw-session" "$BW_SESSION"}
            end
            command bw $argv
        end
      '';
    };
}
