#!/usr/bin/env bash
set -e

# Helper: check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "=== Checking OpenCode installation ==="

if ! command_exists opencode; then
    echo "OpenCode not found. Installing..."
    curl -fsSL https://opencode.ai/install | bash -s -- -v 1.15.13
else
    echo "OpenCode is installed."
fi

echo "=== Checking Ollama installation ==="

if ! command_exists ollama; then
    echo "Ollama is not installed. Please install it from https://ollama.com/download"
    exit 1
else
    echo "Ollama detected."
fi

# Detect Ollama host
if [ -n "$OLLAMA_HOST" ]; then
    OLLAMA_URL="$OLLAMA_HOST"
else
    # Try default
    if curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then
        OLLAMA_URL="http://localhost:11434"
    else
        # Try common alternative ports
        for PORT in 11435 11436 8080 8000; do
            if curl -fsS "http://localhost:$PORT/api/tags" >/dev/null 2>&1; then
                OLLAMA_URL="http://localhost:$PORT"
                break
            fi
        done
    fi
fi

if [ -z "$OLLAMA_URL" ]; then
    echo "Could not detect Ollama host. Please set OLLAMA_HOST."
    exit 1
fi

echo "Detected Ollama host: $OLLAMA_URL"

echo "=== Detecting installed Ollama models ==="

MODELS=$(ollama list | awk 'NR>1 {print $1}')

if [ -z "$MODELS" ]; then
    echo "No Ollama models found. You may want to run: ollama pull llama2"
else
    echo "Found models:"
    echo "$MODELS"
fi

echo "=== Preparing OpenCode config ==="

CONFIG_DIR="$HOME/.opencode"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

mkdir -p "$CONFIG_DIR"

# If config exists, back it up
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    echo "Existing config backed up to config.yaml.bak"
fi

echo "=== Writing new config ==="

{
    echo "providers:"
    echo "  ollama:"
    echo "    type: ollama"
    echo "    host: $OLLAMA_URL"
    echo "    models:"
    for model in $MODELS; do
        echo "      - $model"
    done
} > "$CONFIG_FILE"

echo "Config written to $CONFIG_FILE"

echo "=== Testing OpenCode provider detection ==="

opencode providers list || true

echo "=== Done ==="
