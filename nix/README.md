# nix

One flake for every machine: a bare metal NixOS host, a NixOS host running
under WSL, and a MacBook running nix-darwin. Home Manager is a module of the
system configuration on all three, so one command activates the system and the
user environment together.

## Layout

The flake follows the [dendritic pattern](https://github.com/mightyiam/dendritic).
`flake.nix` only declares inputs; every `.nix` file under `modules/` is a
[flake-parts](https://flake.parts) module, imported automatically by
[import-tree](https://github.com/vic/import-tree). Each file is one feature,
named by its path, and it contributes to whichever layers that feature touches:
`modules/fish.nix` enables fish system-wide, makes it the login shell on NixOS
and on macOS, and configures it in Home Manager, all in one place.

The NixOS, nix-darwin and Home Manager modules are stored as values of the
top-level configuration, under a few names that any file can add to
(`modules/flake/lower-modules.nix`):

| Name                  | Layers                        | Applies to                     |
| --------------------- | ----------------------------- | ------------------------------ |
| `nixos.base`          | NixOS                         | every NixOS host               |
| `darwin.base`         | nix-darwin                    | every macOS host               |
| `homeManager.base`    | Home Manager                  | every host                     |
| `nixos.desktop`       | NixOS (+ HM `desktop`, `gui`) | hosts running the niri desktop |
| `homeManager.desktop` | Home Manager                  | brought in by `nixos.desktop`  |
| `homeManager.gui`     | Home Manager                  | hosts with a display (kitty)   |

Hosts live in `modules/hosts`. Each one defines its own
`nixosConfigurations.<name>` or `darwinConfigurations.<name>` from the names it
wants plus whatever is particular to that machine, Home Manager settings
included (through `home-manager.sharedModules`).

Nothing is passed through `specialArgs`. A module that needs a flake input
closes over `inputs`; the colour scheme is a top-level value (`colors`); the
user and the configuration's name are system options (`my.username`,
`my.hostName`, set by each host) that Home Manager modules read through
`osConfig`.

Files whose path starts with `_` are skipped by import-tree. That is how
`modules/hosts/loq/_hardware-configuration.nix`, an ordinary NixOS module,
lives among them. The dev shells in `shells/` are plain `{ pkgs }:` files,
outside `modules/` altogether.

The configuration this flake does _not_ generate lives one level up, one flat
directory per program: `../nvim`, `../tmux`, `../ranger`, `../kitty`,
`../aerospace`, `../niri`. The feature module for each symlinks it into place
out of the Nix store, so editing them takes effect without a rebuild.

fish is the login shell on every host, configured in `modules/fish.nix`.
bash and zsh are installed but carry no configuration of their own.

Where a difference is a property of the platform rather than of the machine,
put it under `nixos.base` or `darwin.base` in the feature's file, or guard it
inside a Home Manager module with `pkgs.stdenv.hostPlatform.isDarwin`.

## Rebuilding

Every host has a `rebuild` alias, which runs [nh](https://github.com/nix-community/nh)
against this flake (`NH_FLAKE`) with the host's name spelled out:

```sh
nh os switch -H loq        # NixOS, bare metal
nh os switch -H wsl        # NixOS, WSL
nh darwin switch -H macbook
```

Before nh is installed, use the plain commands:

```sh
sudo nixos-rebuild switch --flake '~/dotfiles/nix#loq'
sudo darwin-rebuild switch --flake '~/dotfiles/nix#macbook'
```

Quote the flake reference. fish does not need it, but zsh with `extendedglob`
treats the `#` as a glob operator and fails with `no matches found` -- and
zsh is what a fresh macOS install starts in.

Untracked files are invisible to a flake in a git repository, so `git add` a
new module before rebuilding.

## Installing NixOS

`modules/hosts/loq` imports a `_hardware-configuration.nix` that only the machine
itself can produce, so the host does not evaluate until it exists. From the
installer, with the target partitioned and mounted at `/mnt`:

```sh
nix-shell -p git
nixos-generate-config --root /mnt
git clone <this repository> /mnt/home/zi/dotfiles
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/zi/dotfiles/nix/modules/hosts/loq/_hardware-configuration.nix
git -C /mnt/home/zi/dotfiles add nix/modules/hosts/loq/_hardware-configuration.nix
nixos-install --flake '/mnt/home/zi/dotfiles/nix#loq'
```

Before the last step, make `system.stateVersion` in `modules/hosts/loq/default.nix`
match the one in the generated `/mnt/etc/nixos/configuration.nix`. After the
first boot, give the user a password with `passwd zi` (as
root) and fix the ownership of `~/dotfiles`.

## The NixOS desktop

`#loq` is a Lenovo LOQ laptop running [niri](https://github.com/YaLTeR/niri),
logged into from `tuigreet` on greetd. It is all in
`modules/desktop`: the system side and the hookup in `niri.nix`, the
session's launcher (fuzzel) and notifications (mako) in `session.nix`, the bar
in `waybar.nix`, locking (swaylock, swayidle) in `lock.nix`; niri itself reads `../niri/config.kdl`.

As under AeroSpace, Alt is the window manager's modifier and Super is left to
kitty. Alt+Shift+/ lists the bindings. The Intel GPU drives the desktop; run
something on the RTX 4050 with `nvidia-offload <program>`.

The WSL host is `#wsl`; it gets NixOS-WSL from the `nixos-wsl` input, and
everything WSL-specific, the GPU passthrough included, stays in `modules/hosts/wsl.nix`.

## Bootstrapping macOS

nix-darwin is not installed yet. Once, from this directory:

```sh
nix build '.#darwinConfigurations.macbook.system'
sudo ./result/sw/bin/darwin-rebuild switch --flake '.#macbook'
```

Building first, then calling the result directly, avoids `sudo` on macOS
resetting `PATH` to one that has no `nix` on it.

Nix itself stays under the Lix installer's control; see the comment on
`nix.enable` in `modules/nix-settings.nix`.

## Dev shells

Language toolchains are deliberately absent from the global profile. Each is a
shell instead, one per file in `shells/`: `c`, `elixir`, `go`, `infra`, `lua`,
`ocaml`, `python`, `rust`, `typst`, `web`, `zig`. A new file there becomes a
shell of the same name.

```sh
nix develop '~/dotfiles/nix#rust'
```

direnv is enabled, so a project picks its own with a one-line `.envrc`:

```sh
echo 'use flake ~/dotfiles/nix#go' > .envrc && direnv allow
```

Neovim reads its language servers from whichever shell it was launched in --
there is no mason. The two exceptions are `lua-language-server` and `nixd`,
which are in the global profile because this repository itself is Lua and Nix.

## Homebrew

macOS keeps Homebrew, but only as a cask installer, declared in
`modules/hosts/macbook.nix`. `onActivation.cleanup = "zap"` means every
rebuild uninstalls anything not listed there, so a formula can never end up
shadowing the same program from Nix. Command line tools belong in
`modules/packages.nix` (or a feature's own module) instead.
