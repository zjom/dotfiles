# Google Chrome, enrolled in Chrome Browser Cloud Management.
#
# The enrollment token is the CHROME_ENROLLMENT_TOKEN secret. Chrome reads it
# from /etc/opt/chrome/policies/enrollment at start. A service decrypts it there
# on each boot with the age key of the user, so the token is not in the Nix
# store. Without the key, the service fails and Chrome stays unmanaged.
{
  flake.modules.nixos.chrome =
    { config, pkgs, ... }:
    let
      user = config.users.users.${config.my.username};
    in
    {
      environment.systemPackages = [ pkgs.google-chrome ];

      systemd.services.chrome-enrollment-token = {
        description = "Decrypt the Chrome enrollment token";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        environment.SOPS_AGE_KEY_FILE = "${user.home}/.config/sops/age/keys.txt";
        path = [ pkgs.sops ];
        script = ''
          dir=/etc/opt/chrome/policies/enrollment
          install -d -m 0755 "$dir"
          token=$(sops -d --extract '["CHROME_ENROLLMENT_TOKEN"]' ${../../secrets/secrets.yaml})
          # Chrome runs as the user and must read the token.
          install -m 0440 -o root -g ${user.group} /dev/stdin "$dir/CloudManagementEnrollmentToken" <<<"$token"
        '';
      };
    };
}
