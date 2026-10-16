# dotfiles

One flake configures 3 hosts:

| Host      | System                       |
| --------- | ---------------------------- |
| `loq`     | NixOS on a Lenovo LOQ laptop |
| `wsl`     | NixOS on WSL                 |
| `macbook` | nix-darwin on a MacBook      |

Each program gets its configuration inside its package, so a configured program is the same on each host. You can run one part of the configuration alone:

```sh
nix run github:zjom/dotfiles#fish   # one leaf
nix run github:zjom/dotfiles        # the full command-line environment (env)
```

## Layout

```
lib/        the node framework (graph.nix), shared settings, nixpkgs, overlays
features/   one directory for each feature
hosts/      nixosConfigurations and darwinConfigurations
hardware/   NixOS modules for hardware components
shells/     one dev shell in each file
```

import-tree loads each `.nix` file in `lib/`, `features/`, `hosts/` and `hardware/` as a flake-parts module. import-tree skips each path that contains `/_`.

## Nodes

A node is a module in `nodes.<name>`. Each node is a `nix run` target, a NixOS module and a nix-darwin module.

- A leaf configures one program with [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules). The wrapper makes the program ignore its files in `~/.config`. A leaf does not refer to other nodes.
- A composite imports nodes and adds the glue between them: aliases, key bindings and environment variables.

The rules of the layout:

1. A directory that contains `.nix` files is a feature. A directory that contains no `.nix` files contains configuration data of the feature (`features/editor/nvim/`).
2. The file `<program>.nix` defines the leaf `nodes.<program>`. The file can also contain the Home Manager service that runs the program.
3. The file `<feature>/default.nix` defines the composite `nodes.<feature>`, and the NixOS, nix-darwin and Home Manager modules of the feature. The composite of `features/git/` is `nodes.git-ui`, because `nodes.git` is the leaf.
4. A file with another name contains only NixOS, nix-darwin or Home Manager modules.
5. The configuration files of a leaf are in the same directory as the leaf.
6. Glue between two programs goes in the feature that uses the glue.

Values that more than one program uses, for example the colours, are `settings.*` options in `lib/settings.nix`.

## Adding a program

Use the first rule that applies:

1. The program has no configuration: add the program to the `packages` option of a composite. If no composite uses the program, add the program to `features/base/packages.nix`.
2. The program has configuration and keeps no state: add a leaf `<program>.nix` with the `leaf` helper of `lib/graph.nix`.
3. The program is a daemon, or the program writes its own configuration: add a Home Manager module to the feature.
4. A value is different on each machine: set the value in the file of the host.

A flake does not see untracked files. Use `git add` for each new file before you rebuild.

## Rebuilding

Each host has a `rebuild` alias that runs [nh](https://github.com/nix-community/nh) on `~/dotfiles`:

```sh
nh os switch -H loq
nh os switch -H wsl
nh darwin switch -H macbook
```

To evaluate each node, each host and each dev shell on each system, run `nix flake check --no-build --all-systems`.

## Installing NixOS on loq

Partition the target disk. Mount the target disk at `/mnt`. Then run these commands in the installer:

```sh
nix-shell -p git
nixos-generate-config --root /mnt
git clone <this repository> /mnt/home/zi/dotfiles
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/zi/dotfiles/hosts/loq/_hardware-configuration.nix
git -C /mnt/home/zi/dotfiles add hosts/loq/_hardware-configuration.nix
nixos-install --flake '/mnt/home/zi/dotfiles#loq'
```

Before you run `nixos-install`, set `system.stateVersion` in `hosts/loq/default.nix` to the value in `/mnt/etc/nixos/configuration.nix`. After the first boot, set a password with `passwd zi` and make `zi` the owner of `~/dotfiles`.

## Bootstrapping macOS

Run these commands one time, from the root of the repository:

```sh
nix build '.#darwinConfigurations.macbook.system'
sudo ./result/sw/bin/darwin-rebuild switch --flake '.#macbook'
```

`sudo` on macOS removes `nix` from `PATH`. Thus, the second command runs `darwin-rebuild` from the build result.

## Dev shells

Each file in `shells/` is a dev shell with the same name. The global profile contains no language toolchains.

```sh
nix develop '~/dotfiles#rust'
echo 'use flake ~/dotfiles#go' > .envrc && direnv allow
```

In fish, F12 opens a picker of the dev shells. Neovim gets its language servers from the dev shell.
