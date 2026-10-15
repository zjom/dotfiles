# dotfiles

This repository is one flake for all machines. The flake configures three hosts:

- `loq`: a NixOS host on bare metal.
- `wsl`: a NixOS host that runs under WSL.
- `macbook`: a MacBook that runs nix-darwin.

The repository follows the nix-env-graph design. In this design, the
configuration of each program is part of the package of that program. Thus, a
configured program is the same on all hosts. You can also run one part of the
configuration without the other parts:

```sh
nix run github:zjom/dotfiles#fish     # fish with the configuration of this repository
nix run github:zjom/dotfiles#tmux
nix run github:zjom/dotfiles          # the full command-line environment (env)
```

## The graph

Each `.nix` file in the `modules/` directory is a
[flake-parts](https://flake.parts) module.
[import-tree](https://github.com/vic/import-tree) loads these modules.
import-tree skips each path that contains `/_`. The `flake.nix` file declares
only the inputs.

```
flake.nix                    the inputs and the mkFlake call (import-tree ./modules)
modules/
  graph.nix                  the definition of a node; converts nodes to packages, checks and flake.modules
  settings.nix               the shared settings.* options (colours, search ignores)
  nixpkgs.nix                one nixpkgs (overlays, allowUnfree) for the hosts and for `nix run`
  nodes/<name>.nix           one node in each file
  hardware/<name>.nix        flake.modules.nixos.<name>
  system/                    the NixOS, nix-darwin and Home Manager modules that are not nodes
  hosts/<name>               nixosConfigurations and darwinConfigurations
  flake/                     the dev shells and the formatter
shells/                      one dev shell in each file
nvim/ kitty/ ranger/ niri/ aerospace/ scripts/   the configuration files that the nodes read
```

A **node** is a module that is declared as `nodes.<name>`. A node sets only
these options:

- `wrappers.<program>.*` options from
  [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).
- The `entry` option of the node.
- `settings.*` options.

The wrapper starts the program with the configuration from the Nix store. The
wrapper ignores the `~/.config` directory. One node file is a `nix run` target,
a NixOS module and a nix-darwin module. To use a node, a host imports the node
file.

There are two types of node:

- A **leaf** configures one program and does not refer to other programs. The
  leaves are `fish`, `tmux`, `nvim`, `kitty`, `ranger`, `git`, `bat`, `eza`,
  `fd`, `ripgrep`, `fzf`, `starship`, `zoxide`, `direnv`, `lazygit`, `sesh`,
  `nh`, `bw`, `bws`, `spotify-player`, `niri`, `waybar`, `mako`, `swaylock`,
  `lm10` and `aerospace`.
- A **composite** imports nodes through `config.nodes.<name>`. A composite adds
  only the glue between these nodes:

  | Composite | Glue |
  | --- | --- |
  | `shell` | fish, tmux and sesh: the session pickers, the default shell of tmux, `FZF_TMUX` |
  | `search` | fish with fzf, fd, rg, bat and nvim: `ff`, `nr`, the key bindings of fzf, `PAGER` |
  | `files` | fish, tmux, ranger and eza: `ranger_cd`, the alt-r binding, the `ls` aliases |
  | `prompt` | the hooks of starship, zoxide and direnv in fish |
  | `editor` | nvim as `EDITOR` and as the editor of git; the pane navigation between tmux and nvim |
  | `git-ui` | lazygit in a tmux popup |
  | `github` | the credential helper of git, through gh |
  | `devshell` | the dev shell picker on F12; the git ignore entry for `.direnv/` |
  | `bitwarden` | `bw` and `bws`, with their secrets in the keyring of the OS |
  | `env` | all composites above, plus nh and spotify-player; the default package |
  | `launcher` | the lm10 pickers in `scripts/lm10` |
  | `desktop` | the niri bindings and the waybar buttons that start kitty, ranger and the pickers |
  | `mac-desktop` | the AeroSpace bindings that start kitty and tmux |

Some values are necessary for more than one program. Examples are the colour
scheme and the directories that the search tools skip. These values are
`settings.*` options in `modules/settings.nix`. A composite or a host can
override each value. All nodes in the same evaluation then use the new value.

### Rules

- A leaf configures exactly one program. The leaf makes the program ignore the
  user configuration of the program. The leaf sets
  `entry = lib.mkDefault "<binary>"`. The leaf does not name the program of
  another node. The leaf can call commands that are not nodes, for example
  `sudo`, `nix`, `nb`, `wpctl` and `firefox` (D17).
- A composite contains only glue. If only one program needs a setting, the
  setting belongs in the leaf of that program. Some composites import other
  composites that start different programs. Such a composite must use
  `lib.mkForce` to select its `entry`. If the composite does not use
  `lib.mkForce`, the evaluation fails with a conflict error. The error names
  both programs.
- A node never tests the host or the module system that contains the node.
  Tests of `pkgs.stdenv` are permitted.
- A host gets configured programs only through the nodes that the host
  imports. Some settings exist only on one platform: the login shell, the flake
  path of `nh`, the `rebuild` alias and the device name for Spotify. The host,
  or a module in `modules/system`, sets these values on top of the node.
- Some programs are daemons that keep state, or programs that write their own
  configuration: spotifyd, swayidle, cliphist, gh and devenv. These programs are
  not nodes. Home Manager manages these programs. Home Manager also manages the
  file associations and the theme of the session. Home Manager runs the
  services with the wrappers.
- Hardware support uses one hardware node for each component: `intel-cpu`,
  `laptop`, `audio` and `nvidia-prime`. Each policy value in a hardware node
  uses `lib.mkDefault`.

Changes to the configuration files do not apply immediately. If you edit the
files in `nvim/`, `kitty/`, `niri/` or the other configuration directories, the
change applies after you run `rebuild`. To use the change immediately, run
`nix run .#<node>`.

## Rebuilding

Each host has a `rebuild` alias. The alias runs
[nh](https://github.com/nix-community/nh) on `~/dotfiles` and gives the name of
the host explicitly:

```sh
nh os switch -H loq        # NixOS on bare metal
nh os switch -H wsl        # NixOS on WSL
nh darwin switch -H macbook
```

If nh is not installed, use these commands:

```sh
sudo nixos-rebuild switch --flake '~/dotfiles#loq'
sudo darwin-rebuild switch --flake '~/dotfiles#macbook'
```

Put quotation marks around the flake reference. fish does not need the
quotation marks. But zsh with the `extendedglob` option treats `#` as a glob
operator, and then zsh fails with the error `no matches found`. A new macOS
installation uses zsh as the default shell.

A flake in a git repository does not see untracked files. Thus, before you
rebuild, use the `git add` command to add each new module.

Before you switch, you can run `nix flake check --no-build --all-systems`. This
command evaluates all nodes, all hosts and all dev shells on all systems.

## Installing NixOS

The `modules/hosts/loq` module imports the `_hardware-configuration.nix` file.
Only the target machine can generate this file. The host does not evaluate
until the file exists.

Run these commands in the installer. Before you start, partition the target
disk. Mount the target disk at `/mnt`.

```sh
nix-shell -p git
nixos-generate-config --root /mnt
git clone <this repository> /mnt/home/zi/dotfiles
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/zi/dotfiles/modules/hosts/loq/_hardware-configuration.nix
git -C /mnt/home/zi/dotfiles add modules/hosts/loq/_hardware-configuration.nix
nixos-install --flake '/mnt/home/zi/dotfiles#loq'
```

Before you run the `nixos-install` command, open the generated
`/mnt/etc/nixos/configuration.nix` file. Set `system.stateVersion` in
`modules/hosts/loq/default.nix` to the same value.

After the first boot, do these steps as root:

1. Set a password for the user with `passwd zi`.
2. Change the owner of `~/dotfiles` to the user.

## The NixOS desktop

`#loq` is a Lenovo LOQ laptop. The laptop runs
[niri](https://github.com/YaLTeR/niri). The user logs in through `tuigreet` on
greetd. The programs are the nodes `niri`, `waybar`, `mako`, `swaylock` and
`lm10`. The `desktop` composite combines these nodes. niri reads
`niri/config.kdl`. The system configuration and the services of the session
are in `modules/system/desktop`.

Alt is the modifier key of the window manager, the same as under AeroSpace.
kitty uses the Super key. Alt+Shift+/ shows a list of the bindings. The Intel
GPU renders the desktop. To run a program on the RTX 4050, use
`nvidia-offload <program>`.

The WSL host is `#wsl`. This host gets NixOS-WSL from the `nixos-wsl` input.
All WSL-specific configuration, including the GPU passthrough, is in
`modules/hosts/wsl.nix`.

## Bootstrapping macOS

At first, nix-darwin is not installed. Run these commands one time, from the
root of the repository:

```sh
nix build '.#darwinConfigurations.macbook.system'
sudo ./result/sw/bin/darwin-rebuild switch --flake '.#macbook'
```

The commands build the system first and then run `darwin-rebuild` from the
build result. This order is necessary because `sudo` on macOS sets `PATH` to a
value that does not contain `nix`.

The Lix installer continues to control Nix itself. For more information, see
the comment on `nix.enable` in `modules/system/nix-settings.nix`.

## Dev shells

The global profile intentionally does not contain language toolchains. Each
toolchain is a dev shell. Each file in `shells/` defines one dev shell: `c`,
`elixir`, `go`, `infra`, `lua`, `ocaml`, `python`, `rust`, `typst`, `web` and
`zig`. A new file in `shells/` becomes a dev shell with the same name.

```sh
nix develop '~/dotfiles#rust'
```

direnv is enabled. Thus, a project can select its dev shell with an `.envrc`
file that contains one line:

```sh
echo 'use flake ~/dotfiles#go' > .envrc && direnv allow
```

Neovim gets its language servers from the dev shell that started Neovim. The
configuration does not use mason. The exception is `nixd`. `nixd` is in the
global profile because this repository is written in Nix.

## Homebrew

macOS keeps Homebrew, but only to install casks. `modules/hosts/macbook.nix`
declares the casks. The `onActivation.cleanup = "zap"` option makes each
rebuild uninstall all packages that are not in that list. Thus, a Homebrew
formula cannot shadow a program from Nix. Command-line tools belong in a node.
If a command-line tool does not need configuration, add the tool to
`modules/system/packages.nix`.

## Decision log

D1 to D10 come from the nix-env-graph design. These decisions apply to this
repository without changes:

| #   | Decision |
| --- | --- |
| D1  | Configure programs as wrappers, not as Home Manager modules. |
| D2  | Use nix-wrapper-modules to build the wrappers. |
| D3  | Hosts import nodes directly. There is no adapter that installs built packages. |
| D4  | `graph.nix` gives each node a stable module key. Thus, the module system deduplicates imports that overlap. |
| D5  | Use flake-parts and import-tree for the structure of the flake. |
| D6  | `nix run` puts the programs of the node first on the `PATH` of the entry program. |
| D7  | Use one small `settings.*` namespace for shared values. |
| D8  | An entry conflict is an evaluation error. |
| D9  | Wrappers ignore user configuration files. |
| D10 | Do not override the `meta.platforms` value of upstream wrapper modules. This value is not enforced. |

These decisions apply only to this repository:

| #   | Decision | Reason |
| --- | --- | --- |
| D11 | `modules/nixpkgs.nix` gives `nix run` the same overlays and the same `allowUnfree` value as the hosts. | Without this module, a node builds to a different store path on a host than under `nix run`. |
| D12 | The dev shell loader stays in `modules/flake/dev-shells.nix`. | Dev shells are not nodes. The loader has approximately 12 lines. The loader existed before the graph. |
| D13 | vim.pack installs the Neovim plugins at run time. Home Manager links `~/.config/nvim` to the checkout. vim.pack keeps its lockfile in that directory. | The committed `nvim-pack-lock.json` file pins the plugins. The wrapped Neovim does not load other files from that directory. Under a plain `nix run`, vim.pack starts a new lockfile. |
| D14 | gh, devenv and spotifyd stay with Home Manager. | gh writes its login into its configuration directory. devenv keeps its settings in its configuration directory. spotifyd is a daemon that keeps state. Nodes call gh and devenv by name. |
| D15 | The `runtimePkgs` option of a leaf can contain the tools that the plugins of the program call: git for vim.pack, gcc, tree-sitter and cargo. | These tools are dependencies of the program. These tools are not programs of the graph that the program integrates with. |
| D16 | `x86_64-darwin` is not a target. | nixpkgs 26.11 removed `x86_64-darwin`. |
| D17 | Nodes can call commands that are not nodes, for example `sudo`, `nix`, `nb`, `opencode`, `wpctl` and `firefox`. | Rule 9 applies to the programs of the graph. A plain system command has no configuration that must stay consistent. |
| D18 | A node is a `nix run` target only on the systems that have a package for each program of the node (`graph.nix`). | The desktop nodes are only for Linux. Without this filter, `nix flake check --all-systems` fails on darwin. |
| D19 | The prompt composite sets `DIRENV_CONFIG` in fish to a store path. | `direnv hook` writes the path of the unwrapped binary into the hook. Without this value, the hook runs direnv without its configuration. direnv does not refer back to other nodes, so there is no dependency cycle. |
| D20 | fd gets its ignore patterns from `--ignore-file`. fd still reads its global ignore file. | fd cannot skip the global ignore file unless `XDG_CONFIG_HOME` changes. A change of `XDG_CONFIG_HOME` also applies to each child process of `fd --exec`. No file in this repository writes the global ignore file. |
| D21 | The launcher uses a `buildCommand` entry to link the lm10 scripts into the `bin/` directory of the lm10 wrapper. | A composite can set only `wrappers.*` options. The scripts are glue, not a separate program. lm10-apps lists the scripts in the directory of its own resolved path. |
| D22 | The system fish is the wrapper. The wrapper sources `/etc/fish/config.fish` before its own configuration. | The `--no-config` flag also skips `/etc/fish/config.fish`. NixOS and nix-darwin configure `PATH` in that file. Without that file, a login shell has no system environment. |
