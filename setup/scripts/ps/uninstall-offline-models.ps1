#!/usr/bin/env pwsh

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

# --- Step: Stop Ollama service ---
Start-Step "Stopping Ollama service"
if (Get-Service -Name "Ollama" -ErrorAction SilentlyContinue) {
    try {
        Stop-Service -Name "Ollama" -Force -ErrorAction Stop
        End-Step "ok"
    } catch {
        End-Step "fail"
    }
} else {
    End-Step "skip"
}

# --- Step: Disable Ollama service ---
Start-Step "Disabling Ollama service"
if (Get-Service -Name "Ollama" -ErrorAction SilentlyContinue) {
    try {
        Set-Service -Name "Ollama" -StartupType Disabled
        End-Step "ok"
    } catch {
        End-Step "fail"
    }
} else {
    End-Step "skip"
}

# --- Step: Remove Ollama program files ---
Start-Step "Removing Ollama program files"
$ollamaPath = "C:\Program Files\Ollama"
if (Test-Path $ollamaPath) {
    try {
        Remove-Item -Recurse -Force $ollamaPath
        End-Step "ok"
    } catch {
        End-Step "fail"
    }
} else {
    End-Step "skip"
}

# --- Step: Remove user data directory ---
Start-Step "Removing Ollama user data"
$dataPath = "$env:LOCALAPPDATA\Ollama"
if (Test-Path $dataPath) {
    try {
        Remove-Item -Recurse -Force $dataPath
        End-Step "ok"
    } catch {
        End-Step "fail"
    }
} else {
    End-Step "skip"
}

# --- Step: Remove logs ---
Start-Step "Removing Ollama logs"
$logPath = "$env:LOCALAPPDATA\Ollama\Logs"
if (Test-Path $logPath) {
    try {
        Remove-Item -Recurse -Force $logPath
        End-Step "ok"
    } catch {
        End-Step "fail"
    }
} else {
    End-Step "skip"
}

# --- Step: Remove uninstall entry ---
Start-Step "Removing uninstall registry entry"
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Ollama"
if (Test-Path $regPath) {
    try {
        Remove-Item -Recurse -Force $regPath
        End-Step "ok"
    } catch {
        End-Step "fail"
    }
} else {
    End-Step "skip"
}

Write-Host "Ollama uninstall and cleanup complete."
