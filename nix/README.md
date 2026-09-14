# nix

One flake for every machine: a NixOS host running under WSL, and a MacBook
running nix-darwin. Home Manager is a module of the system configuration on
both, so one command activates the system and the user environment together.

## Layout

| Path                  | Scope                                            |
| --------------------- | ------------------------------------------------ |
| `modules/home/`       | Home Manager, shared by every host                |
| `modules/system/`     | System level; `common.nix`, then `nixos.nix` or `darwin.nix` |
| `hosts/<name>/default.nix` | System level, that host only                 |
| `hosts/<name>/home.nix`    | Home Manager, that host only                 |
| `shells/`             | Per-language dev shells                           |

The configuration this flake does *not* generate lives one level up, one flat
directory per program: `../nvim`, `../tmux`, `../ranger`, `../kitty`,
`../aerospace`. `modules/home/dotfiles.nix` symlinks those into place out of
the Nix store, so editing them takes effect without a rebuild.

`modules/home/options.nix` declares the options this configuration adds for
itself, all under the `my` prefix. `my.shell.aliases` is the one worth knowing:
shared and host-only definitions are merged, so `hosts/*/home.nix` adds the
`rebuild` alias without restating the shared set.

Where a difference is a property of the platform rather than of the machine,
put it in `modules/system/{nixos,darwin}.nix`, or guard it inside a shared
Home Manager module with `pkgs.stdenv.isDarwin`.

## Rebuilding

Both hosts have a `rebuild` alias pointing at this flake.

```sh
# WSL
sudo nixos-rebuild switch --flake '~/dotfiles/nix#nixos'

# macOS
sudo darwin-rebuild switch --flake '~/dotfiles/nix#macbook'
```

Quote the flake reference. zsh with `extendedglob` treats the `#` as a glob
operator and fails with `no matches found`.

Untracked files are invisible to a flake in a git repository, so `git add` a
new module before rebuilding.

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
