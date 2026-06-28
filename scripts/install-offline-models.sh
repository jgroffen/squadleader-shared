#!/usr/bin/env bash

echo "Offline Model Installer and Setup"

# --- Color Codes ---
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# --- Status Helpers ---
start_step() {
  local msg="$1"
  local nonewline="${2:-false}"
  CURRENT_STEP="$msg"
  if [[ "$nonewline" == "true" ]]; then
    printf "[....] %s\r" "$msg"
  else
    printf "[....] %s\n" "$msg"
  fi
}

end_step() {
  STATUS="$1"
  case "$STATUS" in
    ok)
      printf "[${GREEN}DONE${NC}] %s\n" "$CURRENT_STEP"
      ;;
    fail)
      printf "[${RED}FAIL${NC}] %s\n" "$CURRENT_STEP"
      ;;
    skip)
      printf "[${YELLOW}SKIP${NC}] %s\n" "$CURRENT_STEP"
      ;;
  esac
}

# Escape regex special chars for grep -E
escape_for_grep_e() {
  local s="$1"
  # Escape characters that are special in ERE
  printf '%s' "$s" | sed -e 's/[]\/$*.^[]/\\&/g'
}

install_model() {
  local modelName="$1"
  local friendlyName="$2"

  start_step "Checking if $friendlyName model is installed" true

  # Query installed models (suppress stderr)
  local models
  if ! models="$(ollama list 2>/dev/null)"; then
    # If list failed, treat as not installed
    end_step "ok"
  else
    # Check for exact model name at start of line
    local esc
    esc="$(escape_for_grep_e "$modelName")"
    if printf '%s\n' "$models" | grep -E -q "^${esc}\b"; then
      end_step "skip"
      return 0
    else
      end_step "ok"
    fi
  fi

  start_step "Pulling $friendlyName model (ollama pull \"$modelName\")" false
  if ollama pull "$modelName"; then
    end_step "ok"
    echo "Successfully pulled model: $modelName"
  else
    end_step "fail"
    echo "Failed to pull model: $modelName"
    return 1
  fi
}

# --- Step: Detect Ollama ---
start_step "Checking if Ollama is installed" true
if command -v ollama >/dev/null 2>&1; then
  end_step skip
else
  end_step ok

  # --- Step: Install Ollama ---
  start_step "Installing Ollama"
  printf "\n"
  if curl -fsSL https://ollama.com/install.sh | sh; then
    end_step ok
  else
    end_step fail
    echo "Installation failed. Aborting."
    exit 1
  fi
fi

# Model Shopping: https://ollama.com/library

# Good chat agent for general chat, writing, summaries, balanced tasks
install_model "llama3.1:8b" "Llama 3.1 8B" || true
install_model "llama3.1:70b" "Llama 3.1 70B" || true

# Has tools and works with continue / claude code - looks like it wants 256k context, can take text or images
# https://ollama.com/library/qwen3.5
install_model "qwen3.5:0.8b" "Qwen 3.5 0.8B" || true
install_model "qwen3.5:2b" "Qwen 3.5 2B" || true
install_model "qwen3.5:4b" "Qwen 3.5 4B" || true
install_model "qwen3.5:9b" "Qwen 3.5 9B" || true
install_model "qwen3.5:27b" "Qwen 3.5 27B" || true
install_model "qwen3.5:35b" "Qwen 3.5 35B" || true

# A bit older but coder-focused
install_model "qwen3-coder:30b" "Qwen 3 Coder 30B" || true

# Mixture of Experts model with 4B active parameters, good for multimodal tasks
install_model "gemma4:26b" "Gemma4 26B (4B active)" || true
install_model "gemma4:31b" "Gemma4 31B (Dense)" || true

# Permissive license GPT Model, adjustable reasoning, built-in web searching, python tooling, structured outputs, Quantization - MXFP4
install_model "gpt-oss:20b" "OpenAI GPT 20B" || true
# install_model "gpt-oss:120b" "OpenAI GPT 120B" || true  # WARNING: requires huge resources

# High-quality general chat, coding, creative writing, balanced performance, NVIDIA + Mistral collab. Very strong for it's size.
install_model "mistral-nemo:12b" "Mistral 12B" || true

# shockingly good for it's size - fast and tiny
install_model "phi4-mini:3.8b" "Phi-4 Mini 3.8B" || true

echo "All tasks complete."

# Models that won't work with continue / claude code etc. These models are
# reasoning only and don't support tools. Note deepseek states it does, but it doesn't.

# # Small, fast reasoning agent, good at math and logic problems, and code generation
# install_model "deepseek-r1:1.5b" "DeepSeek R1 1.5B" || true
# install_model "deepseek-r1:7b"   "DeepSeek R1 7B"   || true
# install_model "deepseek-r1:8b" "DeepSeek R1 8B" || true
# install_model "deepseek-r1:14b"  "DeepSeek R1 14B"  || true
# install_model "deepseek-r1:32b"  "DeepSeek R1 32B"  || true

# # Small and fast coding agent, very strong for their size, good at coding, multi-language support
# install_model "deepseek-coder:1.3b" "DeepSeek-Coder 1.3B" || true

# # Medium sized / speed, balanced coding agent, very strong for their size, good at coding, multi-language support
# install_model "deepseek-coder:6.7b" "DeepSeek-Coder 6.7B" || true

# # Higher reasoning coding agent, good at coding, multi-language support
# install_model "deepseek-coder:33b"  "DeepSeek-Coder 33B"  || true

# # built on Google Gemini, can process text and images, good for multimodal tasks, great bang-for-buck
# install_model "gemma3:1b" "Gemma3 1B" || true
# install_model "gemma3:4b" "Gemma3 4B" || true
# install_model "gemma3:12b" "Gemma3 12B" || true
# install_model "gemma3:27b" "Gemma3 27B" || true

# # Quantised tags:
# # - "gemma3:4b-it-quat"
# # - "gemma3:27b-it-quat"

# install_model "llama3:8b" "Llama 3 8B" || true

# # Excellent coding model, good for code generation, code understanding, and code-related tasks. Based on Llama 2 architecture, trained on a large corpus of code.
# install_model "codellama:13b" "CodeLlama 13B" || true

# # Vision-capable model, good for image understanding tasks, including OCR, image classification, and image-based reasoning
# install_model "llava-phi3" "Llava Phi3" || true

# # The models were trained against LLaMA-7B with a subset of the dataset, responses that contained alignment / moralizing were removed
# install_model "wizard-vicuna-uncensored:7b"  "Wizard Vicuna Uncensored 7B"  || true
# install_model "wizard-vicuna-uncensored:13b" "Wizard Vicuna Uncensored 13B" || true
# install_model "wizard-vicuna-uncensored:30b" "Wizard Vicuna Uncensored 30B" || true

# # Quantised Tags:
# # - wizard-vicuna-uncensored:7b-q4_0
# # - wizard-vicuna-uncensored:13b-q4_0
# # - wizard-vicuna-uncensored:30b-q4_0

# # Fast, small, and high-quality embeddings, good for semantic search, vector databases, and retrieval tasks
# install_model "nomic-embed-text" "Nomic Embed Text" || true
