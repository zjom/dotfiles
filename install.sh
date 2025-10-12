#!/bin/bash

BREWFILE_PATH="./homebrew/.config/homebrew/Brewfile"

if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..." >&2
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v brew &> /dev/null; then
    echo "Homebrew installation failed or is not available." >&2
    exit 1
fi

dependencies = $(brew bundle list --file="$BREWFILE_PATH")
echo "The following dependencies will be installed." >&2
echo $dependencies
read -p "Install (Y/n)" confirmation
if [[ "$confirmation" =~ ^[Yy]$ || -z "$confirmation" ]]; then
    echo "Installing brew bundle files..." >&2
    brew bundle install --file="$BREWFILE_PATH" --upgrade
else
    echo "Installation cancelled." >&2
    exit 1
fi

if ! command -v stow &> /dev/null; then
    echo "Stow not found. Installing stow..." >&2
    brew install stow
fi

echo "Creating simlinks with stow..." >&2
stow *

echo "le epic gamer time"
