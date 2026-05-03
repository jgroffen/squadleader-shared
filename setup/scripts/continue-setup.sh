#!/usr/bin/env bash

CONFIG_FILE="$HOME/.continue/config.yaml"

# --- 1. Write the static block (overwrite file) ---
cat <<'EOF' > "$CONFIG_FILE"
%YAML 1.1
---
name: Local Config
version: 1.0.0
schema: v1

model_defaults: &model_defaults
  provider: ollama
  apiBase: http://caladan.local:11434
  params:
    max_tokens: 1024
    temperature: 0.2

# Continue global config - local-only, disable hub/sync/telemetry
core:
  offline: true
  allow_hub: false
  allow_sync: false
  require_account: false
  auto_update: false
  telemetry:
    enabled: false
    analytics: false

defaults:
  model: "gemma4:26b"
  preview_edits: true
  require_confirm: true

models:
EOF

# --- 2. Loop through installed models ---
ollama list | tail -n +2 | awk '{print $1}' | while read -r model; do
  show_out=$(ollama show "$model" 2>/dev/null)

  params=$(printf '%s\n' "$show_out" | awk '/^[[:space:]]*parameters[[:space:]]+[0-9]/{print $2; exit}')
  family=$(printf '%s\n' "$show_out" | awk '/^[[:space:]]*architecture[[:space:]]+/{print $2; exit}')
  quant=$(printf '%s\n' "$show_out" | awk '/^[[:space:]]*quantization[[:space:]]+/{print $2; exit}')
  ctx=$(printf '%s\n' "$show_out" | awk '/^[[:space:]]*context length[[:space:]]+/{print $3; exit}')
  has_tools=$(printf '%s\n' "$show_out" | awk '/^[[:space:]]*tools[[:space:]]*$/{print "true"; exit}')

  [ -z "$params" ] && params="unknown parameters"
  [ -z "$family" ] && family="unknown architecture"
  [ -z "$quant" ] && quant="unknown quantization"
  [ -z "$ctx" ] && ctx="unknown context length"

  desc="$family model with $params parameters, $quant quantization, and a $ctx token context window."
  [ "$has_tools" = "true" ] && desc="$desc Supports tools/function calling."

  cat <<EOF >> "$CONFIG_FILE"
  - name: "$model"
    <<: *model_defaults
    model: $model
    description: |
      $desc
EOF
done
