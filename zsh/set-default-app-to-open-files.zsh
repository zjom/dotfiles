#!/bin/bash

APP_ID=$(osascript -e 'id of app "Kitty.app"')
extensions=(
    .txt
    .md
    .json
    .yaml
    .yml
    .toml
    .conf
    .sh
    .zsh
    .py
    .js
    .ts
    .rs
    .lua
    .c
    .cpp
    .h
    public.plain-text  # Catches many generic text files without specific extensions
    public.unix-executable
)

echo "Setting $APP_ID as default for text files..."

for ext in "${extensions[@]}"; do
    # The syntax is: duti -s <bundle_id> <extension> all
    duti -s "$APP_ID" "$ext" all
    echo "Assigned $ext"
done

echo "Done!"
