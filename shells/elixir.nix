# Elixir and Erlang toolchain, with elixir-ls.
#   nix develop '~/dotfiles#elixir'
{ pkgs }:

pkgs.mkShell {
  name = "elixir-dev";

  packages = with pkgs; [
    elixir
    erlang
    elixir-ls
  ];

  # Keep the iex history between sessions.
  env.ERL_AFLAGS = "-kernel shell_history enabled";

  shellHook = ''
    # Keep the hex state and the rebar state in each project, not in ~/.mix.
    export MIX_HOME="$PWD/.mix"
    export HEX_HOME="$PWD/.hex"
    export PATH="$MIX_HOME/bin:$PATH"
    echo "elixir $(elixir --version | tail -1 | cut -d' ' -f2) | $(erl -noshell -eval 'io:format("erlang ~s", [erlang:system_info(otp_release)]), halt().') | elixir-ls"
  '';
}
