#!/usr/bin/env pwsh

Write-Host "Offline Model Installer and Setup"

# --- Color Codes ---
$GREEN  = "`e[32m"
$RED    = "`e[31m"
$YELLOW = "`e[33m"
$NC     = "`e[0m"

# --- Status Helpers ---
function Start-Step($msg) {
    Set-Variable -Name CURRENT_STEP -Value $msg -Scope Script
    Write-Host "[....] $msg" -NoNewline
}

function End-Step($status) {
    switch ($status) {
        "ok"   { Write-Host "`r[$($GREEN)DONE$NC] $CURRENT_STEP" }
        "fail" { Write-Host "`r[$($RED)FAIL$NC] $CURRENT_STEP" }
        "skip" { Write-Host "`r[$($YELLOW)SKIP$NC] $CURRENT_STEP" }
    }
}

function Install-Model($modelName, $friendlyName) {
    Start-Step "Checking if $friendlyName model is installed"

    # Query installed models
    $models = ollama list 2>$null

    if ($models -match "$($modelName.Replace(':','\s+'))") {
        End-Step "skip"
        return
    }

    End-Step "ok"

    Start-Step "Pulling $friendlyName model"
    try {
        ollama pull $modelName | Out-Null
        End-Step "ok"
    }
    catch {
        End-Step "fail"
        Write-Host "Failed to pull model: $modelName"
        exit 1
    }
}

# --- Step: Detect Ollama ---
Start-Step "Checking if Ollama is installed"
if (Get-Command ollama -ErrorAction SilentlyContinue) {
    End-Step "skip"
} else {
    End-Step "ok"

    # --- Step: Install Ollama ---
    Start-Step "Installing Ollama"
    Write-Host ""
    try {
        Invoke-WebRequest https://ollama.com/download/OllamaSetup.exe -OutFile "$env:TEMP\OllamaSetup.exe" -UseBasicParsing
        Start-Process "$env:TEMP\OllamaSetup.exe" -ArgumentList "/S" -Wait
        End-Step "ok"
    }
    catch {
        End-Step "fail"
        Write-Host "Installation failed. Aborting."
        exit 1
    }
}

# Small, fast reasoning agent, good at math and logic problems, and code generation
Install-Model "deepseek-r1:1.5b" "DeepSeek R1 1.5B"

# Medium reasoning agent, high-quality chain-of-thought
Install-Model "deepseek-r1:7b" "DeepSeek R1 7B"

# Large reasoning agent, high-quality chain-of-thought
Install-Model "deepseek-r1:14b" "DeepSeek R1 14B"

# Very large reasoning agent, high-quality chain-of-thought
Install-Model "deepseek-r1:32b" "DeepSeek R1 32B"

# Small and fast coding agent, very strong for their size, good at coding, multi-language support
Install-Model "deepseek‑coder:1.3b" "DeepSeek-Coder 1.3B"

# Medium sized / speed, balanced coding agent, very strong for their size, good at coding, multi-language support
Install-Model "deepseek‑coder:6.7b" "DeepSeek-Coder 6.7B"

# Higher reasoning coding agent, good at coding, multi-language support
Install-Model "deepseek‑coder:33b" "DeepSeek-Coder 33B"

# Good chat agent for general chat, writing, summaries, balanced tasks
Install-Model "llama3:8b" "Llama 3 8B"

# Excellent coding model, good for code generation, code understanding, and code-related tasks. Based on Llama 2 architecture, trained on a large corpus of code.
Install-Model "codellama:13b" "CodeLlama 13B"

# High reasoning, excellent coding model, good for code generation, code understanding, and code-related tasks. Based on Llama 2 architecture, trained on a large corpus of code.
Install-Model "codellama:33b" "DeepSeek-Coder 33B"

# High-quality general chat, coding, creative writing, balanced performance, NVIDIA + Mistral collab. Very strong for it's size.
Install-Model "mistral‑nemo:12b" "Mistral 12B"

# Fast, small, and high-quality embeddings, good for semantic search, vector databases, and retrieval tasks
Install-Model "nomic‑embed‑text" "Nomic Embed Text"

# Vision-capable model, good for image understanding tasks, including OCR, image classification, and image-based reasoning
Install-Model "llava-phi3" "Llava Phi3"

# shockingly good for it's size - fast and tiny
# Install-Model "phi-3-mini" "Phi-3 Mini"

Write-Host "All tasks complete."
