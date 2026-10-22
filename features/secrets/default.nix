# Secrets, encrypted with sops and age in secrets/secrets.yaml. The keys that can
# decrypt the file are in .sops.yaml. No plaintext secret is stored in this
# repository or in the Nix store.
#
# On each machine, create an age key one time, add its public key to
# .sops.yaml, and run `sops updatekeys secrets/secrets.yaml` on a machine that
# can already decrypt the file:
#
#   mkdir -p ~/.config/sops/age; and age-keygen -o ~/.config/sops/age/keys.txt
#
# Run a command with the secrets in its environment:
#
#   with-secrets <command> [args...]
#
# Edit the secrets with `sops secrets/secrets.yaml`.
{ config, ... }:
{
  nodes.secrets =
    { pkgs, ... }:
    {
      imports = with config.nodes; [
        fish
      ];

      packages = [
        pkgs.sops
        pkgs.age
      ];

      entry = "fish";

      # sops looks for the key in ~/Library/Application Support on macOS. This
      # variable gives all hosts the same path.
      wrappers.fish.configFile.content = ''
        set -q SOPS_AGE_KEY_FILE; or set -gx SOPS_AGE_KEY_FILE ~/.config/sops/age/keys.txt

        function with-secrets --description "Run a command with the secrets of ~/dotfiles in its environment"
            sops exec-env ~/dotfiles/secrets/secrets.yaml (string join ' ' -- (string escape -- $argv))
        end
      '';
    };
}
