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
    printf "[....] %s" "$msg"
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
    printf "\n"
    end_step "ok"
  else
    # Check for exact model name at start of line
    local esc
    esc="$(escape_for_grep_e "$modelName")"
    if printf '%s\n' "$models" | grep -E -q "^${esc}\b"; then
      printf "\n"
      end_step "skip"
      return 0
    else
      printf "\n"
      end_step "ok"
    fi
  fi

  start_step "Pulling $friendlyName model"
  if ollama pull "$modelName" >/dev/null 2>&1; then
    end_step "ok"
    echo "Successfully pulled model: $modelName"
  else
    end_step "fail"
    echo "Failed to pull model: $modelName"
    return 1
  fi
}

# --- Step: Detect Ollama ---
start_step "Checking if Ollama is installed"
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

# Small, fast reasoning agent, good at math and logic problems, and code generation
install_model "deepseek-r1:1.5b" "DeepSeek R1 1.5B" || true

# Medium reasoning agent, high-quality chain-of-thought
install_model "deepseek-r1:7b"   "DeepSeek R1 7B"   || true

# Large reasoning agent, high-quality chain-of-thought
install_model "deepseek-r1:14b"  "DeepSeek R1 14B"  || true

# Very large reasoning agent, high-quality chain-of-thought
install_model "deepseek-r1:32b"  "DeepSeek R1 32B"  || true

# Small and fast coding agent, very strong for their size, good at coding, multi-language support
install_model "deepseek-coder:1.3b" "DeepSeek-Coder 1.3B" || true

# Medium sized / speed, balanced coding agent, very strong for their size, good at coding, multi-language support
install_model "deepseek-coder:6.7b" "DeepSeek-Coder 6.7B" || true

# Higher reasoning coding agent, good at coding, multi-language support
install_model "deepseek-coder:33b"  "DeepSeek-Coder 33B"  || true

# Good chat agent for general chat, writing, summaries, balanced tasks
install_model "llama3:8b" "Llama 3 8B" || true

# Excellent coding model, good for code generation, code understanding, and code-related tasks. Based on Llama 2 architecture, trained on a large corpus of code.
install_model "codellama:13b" "CodeLlama 13B" || true

# built on Google Gemini, can process text and images, good for multimodal tasks, great bang-for-buck
install_model "gemma3:1b" "Gemma3 1B" || true
install_model "gemma3:4b" "Gemma3 4B" || true
install_model "gemma3:12b" "Gemma3 12B" || true
install_model "gemma3:27b" "Gemma3 27B" || true

# Quantised tags:
# - "gemma3:4b-it-quat"
# - "gemma3:27b-it-quat"

# Mixture of Experts model with 4B active parameters, good for multimodal tasks
install_model "gemma4:26b" "Gemma4 26B (4B active)" || true
install_model "gemma4:31b" "Gemma4 31B (Dense)" || true

# Permissive license GPT Model, adjustable reasoning, built-in web searching, python tooling, structured outputs, Quantization - MXFP4
install_model "gpt-oss:20b" "OpenAI GPT 20B" || true
# install_model "gpt-oss:120b" "OpenAI GPT 120B" || true  # WARNING: requires huge resources

# The models were trained against LLaMA-7B with a subset of the dataset, responses that contained alignment / moralizing were removed
install_model "wizard-vicuna-uncensored:7b"  "Wizard Vicuna Uncensored 7B"  || true
install_model "wizard-vicuna-uncensored:13b" "Wizard Vicuna Uncensored 13B" || true
install_model "wizard-vicuna-uncensored:30b" "Wizard Vicuna Uncensored 30B" || true

# Quantised Tags:
# - wizard-vicuna-uncensored:7b-q4_0
# - wizard-vicuna-uncensored:13b-q4_0
# - wizard-vicuna-uncensored:30b-q4_0

# High-quality general chat, coding, creative writing, balanced performance, NVIDIA + Mistral collab. Very strong for it's size.
install_model "mistral-nemo:12b" "Mistral 12B" || true

# Fast, small, and high-quality embeddings, good for semantic search, vector databases, and retrieval tasks
install_model "nomic-embed-text" "Nomic Embed Text" || true

# Vision-capable model, good for image understanding tasks, including OCR, image classification, and image-based reasoning
install_model "llava-phi3" "Llava Phi3" || true

# shockingly good for it's size - fast and tiny
# install_model "phi-3-mini" "Phi-3 Mini" || true

echo "All tasks complete."
