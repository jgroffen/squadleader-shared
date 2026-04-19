#!/bin/bash

# Install yolo alias to bashrc if it doesn't already exist

BASHRC_FILE="$HOME/.bashrc"
ALIAS_LINE="alias yolo='copilot --yolo'"

if grep -Fxq "$ALIAS_LINE" "$BASHRC_FILE"; then
    echo "✓ yolo alias already exists in $BASHRC_FILE"
else
    echo "$ALIAS_LINE" >> "$BASHRC_FILE"
    echo "✓ Added yolo alias to $BASHRC_FILE"
fi

# Source bashrc to apply the alias in the current session
source "$BASHRC_FILE"
echo "✓ Alias loaded. You can now use 'yolo' command."

# Configure git for improved submodule experience
echo ""
echo "Checking git submodule configuration..."

SUBMODULE_RECURSE=$(git config --global submodule.recurse)
PUSH_RECURSE=$(git config --global push.recurseSubmodules)

if [ "$SUBMODULE_RECURSE" = "true" ] && [ "$PUSH_RECURSE" = "on-demand" ]; then
    echo "✓ Git submodule configuration already set"
else
    echo "Superfriends recommends making some changes to your git submodule settings:"
    echo ""
    echo "  git config --global submodule.recurse true"
    echo "  git config --global push.recurseSubmodules on-demand"
    echo ""
    read -p "Would you like to apply these changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git config --global submodule.recurse true
        git config --global push.recurseSubmodules on-demand
        echo "✓ Git submodule configuration applied successfully"
    else
        echo "ℹ Skipped git configuration. You can run the commands manually later"
    fi
fi
