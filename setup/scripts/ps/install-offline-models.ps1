#!/usr/bin/env pwsh

Write-Host "Offline Model Installer and Setup"

$OllamaExe = "C:\Program Files\Ollama\ollama.exe"
if (-not (Test-Path $OllamaExe)) {
    $OllamaExe = "C:\Users\jim\AppData\Local\Programs\Ollama\ollama.exe"
}

# --- Color Codes ---
$ESC = [char]27
$GREEN  = "$ESC[32m"
$RED    = "$ESC[31m"
$YELLOW = "$ESC[33m"
$NC     = "$ESC[0m"

# --- Status Helpers ---
function Start-Step {
    param(
        [string]$msg,
        [switch]$NoNewLine
    )
    Set-Variable -Name CURRENT_STEP -Value $msg -Scope Script
    if ($NoNewLine) {
        Write-Host "[....] $msg" -NoNewline
    } else {
        Write-Host "[....] $msg"
    }
}

function End-Step($status) {
    $CR = [char]13

    $word  = switch ($status) {
        "ok"   { "DONE" }
        "fail" { "FAIL" }
        "skip" { "SKIP" }
    }

    $color = switch ($status) {
        "ok"   { $GREEN }
        "fail" { $RED }
        "skip" { $YELLOW }
    }

    [Console]::Write($CR + "[")
    [Console]::Write($color)
    [Console]::Write($word)
    [Console]::Write($NC)
    [Console]::WriteLine("] $CURRENT_STEP")
}
function Install-Model($modelName, $friendlyName) {
    Start-Step "Checking if $friendlyName model is installed" -NoNewLine

    # Query installed models
    $models = & $OllamaExe list 2>$null

    if ($models -match "^$([Regex]::Escape($modelName))\b") {
        End-Step "skip"
        return
    }

    End-Step "ok"

    Start-Step "Pulling $friendlyName model"
    try {
        & $OllamaExe pull $modelName | Out-Null

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to pull model: $modelName (exit code was $LASTEXITCODE)"
            End-Step "fail"
        } else {
            Write-Host "Successfully pulled model: $modelName"
            End-Step "ok"
        }
    }
    catch {
        End-Step "fail"
        Write-Host "Failed to pull model: $modelName"
    }
}

# --- Step: Detect Ollama ---
Start-Step "Checking if Ollama is installed" -NoNewLine
if (Test-Path $OllamaExe) {
    End-Step "skip"
} else {
    End-Step "ok"

    # --- Step: Install Ollama ---
    Start-Step "Installing Ollama"
    Write-Host ""
    try {
        irm https://ollama.com/install.ps1 | iex
        End-Step "ok"
    }
    catch {
        End-Step "fail"
        Write-Host "Installation failed. Aborting."
        exit 1
    }
}

# Model Shopping: https://ollama.com/library

# Small, fast reasoning agent, good at math and logic problems, and code generation
Install-Model "deepseek-r1:1.5b" "DeepSeek R1 1.5B"

# Medium reasoning agent, high-quality chain-of-thought
Install-Model "deepseek-r1:7b" "DeepSeek R1 7B"

# Large reasoning agent, high-quality chain-of-thought
Install-Model "deepseek-r1:14b" "DeepSeek R1 14B"

# Very large reasoning agent, high-quality chain-of-thought
Install-Model "deepseek-r1:32b" "DeepSeek R1 32B"

# Small and fast coding agent, very strong for their size, good at coding, multi-language support
Install-Model "deepseek-coder:1.3b" "DeepSeek-Coder 1.3B"

# Medium sized / speed, balanced coding agent, very strong for their size, good at coding, multi-language support
Install-Model "deepseek-coder:6.7b" "DeepSeek-Coder 6.7B"

# Higher reasoning coding agent, good at coding, multi-language support
Install-Model "deepseek-coder:33b" "DeepSeek-Coder 33B"

# Good chat agent for general chat, writing, summaries, balanced tasks
Install-Model "llama3:8b" "Llama 3 8B"

# Excellent coding model, good for code generation, code understanding, and code-related tasks. Based on Llama 2 architecture, trained on a large corpus of code.
Install-Model "codellama:13b" "CodeLlama 13B"

# built on Google Gemini, can process text and images, good for multimodal tasks, great bang-for-buck
Install-Model "gemma3:1b" "Gemma3 1B"

# built on Google Gemini, can process text and images, good for multimodal tasks, great bang-for-buck
Install-Model "gemma3:4b" "Gemma3 4B"

# built on Google Gemini, can process text and images, good for multimodal tasks, great bang-for-buck
Install-Model "gemma3:12b" "Gemma3 12B"

# built on Google Gemini, can process text and images, good for multimodal tasks, great bang-for-buck
Install-Model "gemma3:27b" "Gemma3 27B"

# Quantised tags:
# - "gemma3:4b-it-quat"
# - "gemma3:27b-it-quat"

# Mixture of Experts model with 4B active parameters, good for multimodal tasks
Install-Model "gemma4:26b" "Gemma4 26B (4B active)"

# Mixture of Experts model with 4B active parameters, good for multimodal tasks
Install-Model "gemma4:31b" "Gemma4 31B (Dense)"

# Permissive license GPT Model, adjustable reasoning, built-in web searching, python tooling, structured outputs, Quantization - MXFP4
Install-Model "gpt-oss:20b" "OpenAI GPT 20B"

# Permissive license GPT Model, adjustable reasoning, built-in web searching, python tooling, structured outputs, Quantization - MXFP4
# WARNING: Requires 80GB of GPU RAM
# Install-Model "gpt-oss:120b" "OpenAI GPT 120B"

# The models were trained against LLaMA-7B with a subset of the dataset, responses that contained alignment / moralizing were removed
Install-Model "wizard-vicuna-uncensored:7b" "Wizard Vicuna Uncensored 7B"
Install-Model "wizard-vicuna-uncensored:13b" "Wizard Vicuna Uncensored 13B"
Install-Model "wizard-vicuna-uncensored:30b" "Wizard Vicuna Uncensored 30B"

# Quantised Tags:
# - wizard-vicuna-uncensored:7b-q4_0
# - wizard-vicuna-uncensored:13b-q4_0
# - wizard-vicuna-uncensored:30b-q4_0

# High-quality general chat, coding, creative writing, balanced performance, NVIDIA + Mistral collab. Very strong for it's size.
Install-Model "mistral-nemo:12b" "Mistral 12B"

# Fast, small, and high-quality embeddings, good for semantic search, vector databases, and retrieval tasks
Install-Model "nomic-embed-text" "Nomic Embed Text"

# Vision-capable model, good for image understanding tasks, including OCR, image classification, and image-based reasoning
Install-Model "llava-phi3" "Llava Phi3"

# shockingly good for it's size - fast and tiny
# Install-Model "phi-3-mini" "Phi-3 Mini"

Write-Host "All tasks complete."
