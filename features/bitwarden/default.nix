# `bw` and `bws` in fish, with their secrets in the keyring of the OS. No token
# is stored in this repository or in the Nix store.
#
# On each machine, store the machine-account access token for bws one time:
#
#   secret-tool store --label="Bitwarden Secrets Manager" service bws   # Linux
#   security add-generic-password -a $USER -s bws -w                    # macOS
#
# On each machine, run `bw login` one time. After that, the first `bw` call of a
# login session asks for the master password. The keyring then keeps the session
# key, and all other shells use that key until you run `bw lock`.
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

      # The macOS `security` tool accepts the secret only as an argument. Thus,
      # on macOS, the session key is visible in the process list for a short
      # time.
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
      ];

      packages = [
        pkgs.bitwarden-cli
        pkgs.bws
      ]
      # secret-tool, to store the keyring entries.
      ++ lib.optional (!isDarwin) pkgs.libsecret;

      entry = "fish";

      wrappers.fish.configFile.content = ''
        function bws --wraps bws --description "bws, with its access token from the keyring"
            set -lx BWS_ACCESS_TOKEN (${lookup "bws"})
            or begin
                echo "bws: no access token in the keyring, see features/bitwarden/default.nix" >&2
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
