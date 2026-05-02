#!/bin/bash

# Install yolo alias to bashrc if it doesn't already exist

BASHRC_FILE="$HOME/.bashrc"
ALIAS_LINE="alias yolo='copilot --yolo'"
EXPORT_OPENSPEC_TELEMETRY_LINE="export OPENSPEC_TELEMETRY=0"
EXPORT_DNT_LINE="export DO_NOT_TRACK=1"

if grep -Fxq "$ALIAS_LINE" "$BASHRC_FILE"; then
    echo "✓ yolo alias already exists in $BASHRC_FILE"
else
    echo "$ALIAS_LINE" >> "$BASHRC_FILE"
    echo "✓ Added yolo alias to $BASHRC_FILE"
fi

if grep -Fxq "$EXPORT_OPENSPEC_TELEMETRY_LINE" "$BASHRC_FILE"; then
    echo "✓ Telemetry control already exists in $BASHRC_FILE"
else
    echo "$EXPORT_OPENSPEC_TELEMETRY_LINE" >> "$BASHRC_FILE"
    echo "✓ Added telemetry control to $BASHRC_FILE"
fi

if grep -Fxq "$EXPORT_DNT_LINE" "$BASHRC_FILE"; then
    echo "✓ DNT control already exists in $BASHRC_FILE"
else
    echo "$EXPORT_DNT_LINE" >> "$BASHRC_FILE"
    echo "✓ Added DNT control to $BASHRC_FILE"
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
    echo "SquadLeader recommends making some changes to your git submodule settings:"
    echo ""
    echo "  git config --global submodule.recurse true"
    echo "  git config --global push.recurseSubmodules on-demand"
    echo "  git config --global core.editor \"vim\""
    read -p "Would you like to apply these changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git config --global submodule.recurse true
        git config --global push.recurseSubmodules on-demand
        git config --global core.editor "vim"
        echo "✓ Git configuration applied successfully"
    else
        echo "ℹ Skipped git configuration. You can run the commands manually later"
    fi
fi
