# nix

One flake for every machine: a bare metal NixOS host, a NixOS host running
under WSL, and a MacBook running nix-darwin. Home Manager is a module of the
system configuration on all three, so one command activates the system and the
user environment together.

## Layout

| Path                         | Scope                                                    |
| ---------------------------- | -------------------------------------------------------- |
| `modules/home/default.nix`   | Home Manager, every host (imports the shared modules)    |
| `modules/system/common.nix`  | System level, every host                                 |
| `modules/system/<os>.nix`    | System level, every NixOS or every nix-darwin host       |
| `modules/home/{gui,desktop}` | Home Manager, opt-in: imported by the hosts that want it |
| `modules/system/niri.nix`    | System level, opt-in: imported by the hosts that want it |
| `hosts/<name>/default.nix`   | System level, that host only                             |
| `hosts/<name>/home.nix`      | Home Manager, that host only                             |
| `shells/`                    | Per-language dev shells                                  |

`mkHost` in `flake.nix` imports the every-host modules itself, so a host file
lists only its hardware and the opt-in features it uses.

The configuration this flake does _not_ generate lives one level up, one flat
directory per program: `../nvim`, `../tmux`, `../ranger`, `../kitty`,
`../aerospace`, `../niri`. `modules/home/dotfiles.nix` and the host `home.nix`
files symlink those into place out of the Nix store, so editing them takes
effect without a rebuild.

fish is the login shell on every host, configured in `modules/home/shell.nix`.
bash and zsh are installed but carry no configuration of their own.

`modules/home/options.nix` declares the options this configuration adds for
itself, all under the `my` prefix: where the dotfiles checkout and this flake
live, and the colour scheme.

Where a difference is a property of the platform rather than of the machine,
put it in `modules/system/{nixos,darwin}.nix`, or guard it inside a shared
Home Manager module with `pkgs.stdenv.hostPlatform.isDarwin`.

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

`hosts/loq` imports a `hardware-configuration.nix` that only the machine
itself can produce, so the host does not evaluate until it exists. From the
installer, with the target partitioned and mounted at `/mnt`:

```sh
nix-shell -p git
nixos-generate-config --root /mnt
git clone <this repository> /mnt/home/zi/dotfiles
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/zi/dotfiles/nix/hosts/loq/
git -C /mnt/home/zi/dotfiles add nix/hosts/loq/hardware-configuration.nix
nixos-install --flake '/mnt/home/zi/dotfiles/nix#loq'
```

Before the last step, make `system.stateVersion` in `hosts/loq/default.nix`
match the one in the generated `/mnt/etc/nixos/configuration.nix`. After the
first boot, give the user a password with `passwd zi` (as
root) and fix the ownership of `~/dotfiles`.

## The NixOS desktop

`#loq` is a Lenovo LOQ laptop running [niri](https://github.com/YaLTeR/niri),
logged into from `tuigreet` on greetd. The system side is
`modules/system/niri.nix`; the session's bar (waybar), launcher (fuzzel),
notifications (mako) and locking (swaylock, swayidle) are in
`modules/home/desktop`; niri itself reads `../niri/config.kdl`.

As under AeroSpace, Alt is the window manager's modifier and Super is left to
kitty. Alt+Shift+/ lists the bindings. The Intel GPU drives the desktop; run
something on the RTX 4050 with `nvidia-offload <program>`.

The WSL host is `#wsl`; it gets NixOS-WSL from the `nixos-wsl` input, and
everything WSL-specific, the GPU passthrough included, stays in `hosts/wsl`.

## Bootstrapping macOS

nix-darwin is not installed yet. Once, from this directory:

```sh
nix build '.#darwinConfigurations.macbook.system'
sudo ./result/sw/bin/darwin-rebuild switch --flake '.#macbook'
```

Building first, then calling the result directly, avoids `sudo` on macOS
resetting `PATH` to one that has no `nix` on it.

Nix itself stays under the Lix installer's control; see the comment on
`nix.enable` in `modules/system/darwin.nix`.

## Dev shells

Language toolchains are deliberately absent from the global profile. Each is a
shell instead: `c`, `elixir`, `go`, `lua`, `node`, `ocaml`, `python`, `rust`,
`typst`, `zig`.

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
`hosts/macbook/default.nix`. `onActivation.cleanup = "zap"` means every
rebuild uninstalls anything not listed there, so a formula can never end up
shadowing the same program from Nix. Command line tools belong in
`modules/home/packages.nix` instead.
