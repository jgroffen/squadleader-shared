#!/usr/bin/env bash

echo "Offline Model Installer and Setup"

# --- Color Codes ---
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# --- Status Helpers ---
start_step() {
  CURRENT_STEP="$1"
  printf "[....] %s\r" "$CURRENT_STEP"
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

# --- Placeholder for more operations ---
start_step "Running additional setup tasks"
sleep 1
end_step ok

echo "All tasks complete."
