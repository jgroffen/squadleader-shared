#!/usr/bin/env bash

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

# --- Step: Stop Ollama service ---
start_step "Stopping Ollama service"
if systemctl is-active --quiet ollama; then
  if systemctl stop ollama >/dev/null 2>&1; then
    end_step ok
  else
    end_step fail
  fi
else
  end_step skip
fi

# --- Step: Disable Ollama service ---
start_step "Disabling Ollama service"
if systemctl list-unit-files | grep -q ollama.service; then
  if systemctl disable ollama >/dev/null 2>&1; then
    end_step ok
  else
    end_step fail
  fi
else
  end_step skip
fi

# --- Step: Remove systemd service file ---
start_step "Removing systemd service file"
if [ -f /etc/systemd/system/ollama.service ]; then
  if rm -f /etc/systemd/system/ollama.service; then
    systemctl daemon-reload >/dev/null 2>&1
    end_step ok
  else
    end_step fail
  fi
else
  end_step skip
fi

# --- Step: Remove Ollama binary ---
start_step "Removing Ollama binary"
if command -v ollama >/dev/null 2>&1; then
  BIN_PATH="$(command -v ollama)"
  if rm -f "$BIN_PATH"; then
    end_step ok
  else
    end_step fail
  fi
else
  end_step skip
fi

# --- Step: Remove user data directory ---
start_step "Removing ~/.ollama data directory"
if [ -d "$HOME/.ollama" ]; then
  if rm -rf "$HOME/.ollama"; then
    end_step ok
  else
    end_step fail
  fi
else
  end_step skip
fi

# --- Step: Remove system-wide data directory ---
start_step "Removing /usr/share/ollama (if exists)"
if [ -d /usr/share/ollama ]; then
  if rm -rf /usr/share/ollama; then
    end_step ok
  else
    end_step fail
  fi
else
  end_step skip
fi

# --- Step: Remove logs ---
start_step "Removing Ollama logs"
LOG_PATH="/var/log/ollama"
if [ -d "$LOG_PATH" ]; then
  if rm -rf "$LOG_PATH"; then
    end_step ok
  else
    end_step fail
  fi
else
  end_step skip
fi

echo "Ollama uninstall and cleanup complete."
