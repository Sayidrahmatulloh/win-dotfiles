# ============================================================
#  lib/utils.ps1 — Shared utilities for all scripts
# ============================================================

# ── Output ─────────────────────────────────────────────────────────────────────

function Write-Title   { param([string]$Msg) Write-Host "`n  ==> $Msg" -ForegroundColor Cyan    }
function Write-Section { param([string]$Msg) Write-Host "`n  $Msg"      -ForegroundColor White   }
function Write-Done    { param([string]$Msg) Write-Host "  [+] $Msg"    -ForegroundColor Green   }
function Write-Skip    { param([string]$Msg) Write-Host "  [~] $Msg"    -ForegroundColor Gray    }
function Write-Warn    { param([string]$Msg) Write-Host "  [!] $Msg"    -ForegroundColor Yellow  }
function Write-Fail    { param([string]$Msg) Write-Host "  [x] $Msg"    -ForegroundColor Red     }

function Write-Step {
    param([string]$Prefix, [string]$Name, [string]$Status)
    Write-Host $Prefix       -NoNewline -ForegroundColor DarkGray
    Write-Host " $Name"      -NoNewline -ForegroundColor White
    Write-Host "... $Status"             -ForegroundColor DarkGray
}

function Write-Summary {
    param([string]$Label, [hashtable]$Results)

    $divider = '  ' + ('-' * 40)

    Write-Host ''
    Write-Host $divider                                                   -ForegroundColor DarkGray
    Write-Host "  $Label summary:"                                        -ForegroundColor White
    Write-Host ('  [+] Installed : {0}' -f $Results.Installed.Count)    -ForegroundColor Green
    Write-Host ('  [x] Failed    : {0}' -f $Results.Failed.Count)       -ForegroundColor Red

    foreach ($f in $Results.Failed) {
        Write-Host "       - $f" -ForegroundColor DarkRed
    }

    Write-Host $divider -ForegroundColor DarkGray
}
