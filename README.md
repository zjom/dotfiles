# dotfiles

One flake for every machine: a bare metal NixOS host, a NixOS host running
under WSL, and a MacBook running nix-darwin. It follows the nix-env-graph
design: the configuration of each program is part of that program's package,
so the configured program is the same everywhere, and a part of it runs on
its own:

```sh
nix run github:zjom/dotfiles#fish     # fish exactly as configured here
nix run github:zjom/dotfiles#tmux
nix run github:zjom/dotfiles          # the whole command line environment (env)
```

## The graph

Every `.nix` file under `modules/` is a [flake-parts](https://flake.parts)
module, loaded by [import-tree](https://github.com/vic/import-tree); a path with
`/_` in it is skipped. `flake.nix` only declares inputs.

```
flake.nix                    inputs + mkFlake (import-tree ./modules)
modules/
  graph.nix                  what a node is; nodes -> packages, checks, flake.modules
  settings.nix               shared settings.* options (colours, search ignores)
  nixpkgs.nix                one nixpkgs (overlays, allowUnfree) for hosts and `nix run`
  nodes/<name>.nix           one node per file
  hardware/<name>.nix        flake.modules.nixos.<name>
  system/                    NixOS / nix-darwin / Home Manager modules that are not nodes
  hosts/<name>               nixosConfigurations / darwinConfigurations
  flake/                     dev shells, formatter
shells/                      one dev shell per file
nvim/ kitty/ ranger/ niri/ aerospace/ scripts/   configuration the nodes read
```

A **node** is a module declared as `nodes.<name>` that sets only
`wrappers.<program>.*` options (from
[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules)), its
`entry` and `settings.*`. The wrapper starts the program with its configuration
from the store and ignores `~/.config`. The same node file is a `nix run`
target, a NixOS module and a nix-darwin module; a host just imports it.

- A **leaf** configures one program and refers to no other: `fish`, `tmux`,
  `nvim`, `kitty`, `ranger`, `git`, `bat`, `eza`, `fd`, `ripgrep`, `fzf`,
  `starship`, `zoxide`, `direnv`, `lazygit`, `sesh`, `nh`, `bw`, `bws`,
  `spotify-player`, `niri`, `waybar`, `mako`, `swaylock`, `lm10`, `aerospace`.
- A **composite** imports nodes through `config.nodes.<name>` and adds only the
  glue between them:

  | Composite     | Glue                                                                          |
  | ------------- | ----------------------------------------------------------------------------- |
  | `shell`       | fish + tmux + sesh: session pickers, tmux's default shell, `FZF_TMUX`         |
  | `search`      | fish + fzf/fd/rg/bat/nvim: `ff`, `nr`, fzf's key bindings, `PAGER`            |
  | `files`       | fish + tmux + ranger + eza: `ranger_cd`, alt-r, the `ls` aliases               |
  | `prompt`      | fish + starship, zoxide, direnv hooks                                         |
  | `editor`      | nvim as `EDITOR` and git's editor; tmux/nvim pane navigation                   |
  | `git-ui`      | lazygit in a tmux popup                                                       |
  | `github`      | git's credential helper through gh                                            |
  | `devshell`    | F12 dev shell picker; `.direnv/` ignored by git                               |
  | `bitwarden`   | `bw` / `bws` with their secrets in the OS keyring                             |
  | `env`         | all of the above, plus nh and spotify-player; the default package             |
  | `launcher`    | the lm10 pickers in `scripts/lm10`                                            |
  | `desktop`     | niri binds and waybar buttons that start kitty, ranger and the pickers        |
  | `mac-desktop` | AeroSpace binds that start kitty and tmux                                     |

Values more than one program needs (the colour scheme, the directories never
worth searching) are `settings.*` options in `modules/settings.nix`; any
composite or host can override one, and every node in that evaluation follows.

### Rules

- A leaf configures exactly one program, makes it ignore its user configuration,
  sets `entry = lib.mkDefault "<binary>"`, and names no other node's program.
  Commands that are not nodes (`sudo`, `nix`, `nb`, `wpctl`, `firefox`, ...)
  are fine (D17).
- A composite holds only glue. If only one program needs a setting, it belongs
  in that program's leaf. A composite of composites that start different
  programs picks its `entry` with `lib.mkForce`; without that, evaluation fails
  with a conflict naming both.
- A node never tests the host or the module system it is in; `pkgs.stdenv`
  tests are fine.
- A host gets configured programs only by importing nodes. What only a platform
  can express (the login shell, `nh`'s flake path, the `rebuild` alias, the
  Spotify device name) is set by the host, or by a module in `modules/system`,
  on top of the node.
- Programs that are daemons with state, or that write their own configuration
  (spotifyd, swayidle, cliphist, gh, devenv), are not nodes. Home Manager keeps
  them, plus the session's file associations and theme, and runs the services
  with the wrappers.
- Hardware support is one hardware node per component (`intel-cpu`, `laptop`,
  `audio`, `nvidia-prime`), with `lib.mkDefault` on every policy value.

Configuration is no longer live: editing `nvim/`, `kitty/`, `niri/` and the
rest takes effect after `rebuild`, or straight away with `nix run .#<node>`.

## Rebuilding

Every host has a `rebuild` alias, which runs [nh](https://github.com/nix-community/nh)
against `~/dotfiles` with the host's name spelled out:

```sh
nh os switch -H loq        # NixOS, bare metal
nh os switch -H wsl        # NixOS, WSL
nh darwin switch -H macbook
```

Before nh is installed, use the plain commands:

```sh
sudo nixos-rebuild switch --flake '~/dotfiles#loq'
sudo darwin-rebuild switch --flake '~/dotfiles#macbook'
```

Quote the flake reference. fish does not need it, but zsh with `extendedglob`
treats the `#` as a glob operator and fails with `no matches found` -- and
zsh is what a fresh macOS install starts in.

Untracked files are invisible to a flake in a git repository, so `git add` a
new module before rebuilding.

Before switching, `nix flake check --no-build --all-systems` evaluates every
node, host and dev shell on every system.

## Installing NixOS

`modules/hosts/loq` imports a `_hardware-configuration.nix` that only the machine
itself can produce, so the host does not evaluate until it exists. From the
installer, with the target partitioned and mounted at `/mnt`:

```sh
nix-shell -p git
nixos-generate-config --root /mnt
git clone <this repository> /mnt/home/zi/dotfiles
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/zi/dotfiles/modules/hosts/loq/_hardware-configuration.nix
git -C /mnt/home/zi/dotfiles add modules/hosts/loq/_hardware-configuration.nix
nixos-install --flake '/mnt/home/zi/dotfiles#loq'
```

Before the last step, make `system.stateVersion` in `modules/hosts/loq/default.nix`
match the one in the generated `/mnt/etc/nixos/configuration.nix`. After the
first boot, give the user a password with `passwd zi` (as
root) and fix the ownership of `~/dotfiles`.

## The NixOS desktop

`#loq` is a Lenovo LOQ laptop running [niri](https://github.com/YaLTeR/niri),
logged into from `tuigreet` on greetd. The programs are nodes (`niri`,
`waybar`, `mako`, `swaylock`, `lm10`, composed by `desktop`); niri reads
`niri/config.kdl`. The system side and the session's services are in
`modules/system/desktop`.

As under AeroSpace, Alt is the window manager's modifier and Super is left to
kitty. Alt+Shift+/ lists the bindings. The Intel GPU drives the desktop; run
something on the RTX 4050 with `nvidia-offload <program>`.

The WSL host is `#wsl`; it gets NixOS-WSL from the `nixos-wsl` input, and
everything WSL-specific, the GPU passthrough included, stays in `modules/hosts/wsl.nix`.

## Bootstrapping macOS

nix-darwin is not installed yet. Once, from the repository root:

```sh
nix build '.#darwinConfigurations.macbook.system'
sudo ./result/sw/bin/darwin-rebuild switch --flake '.#macbook'
```

Building first, then calling the result directly, avoids `sudo` on macOS
resetting `PATH` to one that has no `nix` on it.

Nix itself stays under the Lix installer's control; see the comment on
`nix.enable` in `modules/system/nix-settings.nix`.

## Dev shells

Language toolchains are deliberately absent from the global profile. Each is a
shell instead, one per file in `shells/`: `c`, `elixir`, `go`, `infra`, `lua`,
`ocaml`, `python`, `rust`, `typst`, `web`, `zig`. A new file there becomes a
shell of the same name.

```sh
nix develop '~/dotfiles#rust'
```

direnv is enabled, so a project picks its own with a one-line `.envrc`:

```sh
echo 'use flake ~/dotfiles#go' > .envrc && direnv allow
```

Neovim reads its language servers from whichever shell it was launched in --
there is no mason. The exception is `nixd`, which is in the global profile
because this repository itself is Nix.

## Homebrew

macOS keeps Homebrew, but only as a cask installer, declared in
`modules/hosts/macbook.nix`. `onActivation.cleanup = "zap"` means every
rebuild uninstalls anything not listed there, so a formula can never end up
shadowing the same program from Nix. Command line tools belong in a node, or
in `modules/system/packages.nix` if they need no configuration.

## Decision log

D1 to D10 come from the nix-env-graph design and hold here unchanged:

| #   | Decision                                                                                  |
| --- | ----------------------------------------------------------------------------------------- |
| D1  | Configure programs as wrappers, not Home Manager modules.                                 |
| D2  | Build the wrappers with nix-wrapper-modules.                                              |
| D3  | Hosts import nodes directly; no adapter that installs built packages.                     |
| D4  | `graph.nix` gives every node a stable module key, so overlapping imports deduplicate.     |
| D5  | flake-parts and import-tree for the flake structure.                                      |
| D6  | `nix run` puts the node's programs first on the entry program's `PATH`.                   |
| D7  | One small `settings.*` namespace for shared values.                                       |
| D8  | An entry conflict is an evaluation error.                                                 |
| D9  | Wrappers ignore user configuration files.                                                 |
| D10 | `meta.platforms` of upstream wrapper modules is not overridden; it is not enforced.       |

Decisions particular to this repository:

| #   | Decision                                                                                                                       | Reason                                                                                                                                                                                         |
| --- | ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D11 | `modules/nixpkgs.nix` gives `nix run` the same overlays and `allowUnfree` as the hosts.                                        | Without it a node builds to a different store path on a host than under `nix run`.                                                                                                              |
| D12 | The dev shell loader stays in `modules/flake/dev-shells.nix`.                                                                  | Dev shells are not nodes; the loader is a dozen lines and predates the graph.                                                                                                                   |
| D13 | vim.pack installs Neovim's plugins at run time. Home Manager links `~/.config/nvim` to the checkout, where vim.pack keeps its lockfile. | The plugins stay pinned by the committed `nvim-pack-lock.json`. The wrapped Neovim never loads anything else from that directory. Under a bare `nix run` the lockfile starts fresh.            |
| D14 | gh, devenv and spotifyd stay with Home Manager.                                                                                 | gh writes its login into its configuration directory; devenv keeps its settings there; spotifyd is a daemon with state. Nodes reach gh and devenv by name.                                      |
| D15 | A leaf's `runtimePkgs` may hold what the program's own plugins shell out to (git for vim.pack, gcc and tree-sitter, cargo).    | Those are dependencies of the program, not other programs it is integrated with.                                                                                                              |
| D16 | `x86_64-darwin` is not a target.                                                                                                | nixpkgs 26.11 dropped it.                                                                                                                                                                      |
| D17 | Nodes may call commands that are not nodes (`sudo`, `nix`, `nb`, `opencode`, `wpctl`, `firefox`, ...).                          | Rule 9 is about the programs of the graph; a plain system command has no configuration to keep consistent.                                                                                     |
| D18 | A node is a `nix run` target only on systems where every program in it is packaged (`graph.nix`).                               | The desktop nodes are Linux-only; without the filter `nix flake check --all-systems` fails on darwin.                                                                                          |
| D19 | The prompt composite exports `DIRENV_CONFIG` into fish by store path.                                                          | `direnv hook` embeds the unwrapped binary's path, so the hook would otherwise run direnv without its configuration. direnv refers to nothing back, so there is no cycle.                         |
| D20 | fd takes its ignores from `--ignore-file`; its global ignore file is still read.                                               | fd cannot skip it without moving `XDG_CONFIG_HOME`, which would leak into every `fd --exec` child. Nothing here writes that file.                                                              |
| D21 | The launcher links the lm10 scripts into the lm10 wrapper's `bin/` through a `buildCommand` entry.                             | A composite may only set `wrappers.*`; the scripts are glue, not a program of their own. lm10-apps lists the scripts beside its own resolved path.                                               |
| D22 | The system fish is the wrapper, and it sources `/etc/fish/config.fish` before its own configuration.                          | `--no-config` also skips that file, which is where NixOS and nix-darwin set up `PATH`; without it a login shell has no system environment.                                                     |
