#!/bin/bash

# Check for Homebrew and install if not present
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Check again for Homebrew before running brew bundle install
if command -v brew &> /dev/null; then
    echo "Installing brew bundle files..."
    brew bundle install
else
    echo "Homebrew installation failed or is not available. Skipping brew bundle install."
fi
