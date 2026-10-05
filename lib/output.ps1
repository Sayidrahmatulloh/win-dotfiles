# Console formatting only. No setup actions run when loaded.
# ============================================================
#  lib/utils.ps1 — Shared helpers for all dotfiles scripts
# ============================================================

# ── ANSI colours ──────────────────────────────────────────────────────────────

$ESC = [char]27
$RESET = "$ESC[0m"
$BOLD = "$ESC[1m"
$DIM = "$ESC[2m"

$GRAY = "$ESC[90m"
$LRED = "$ESC[91m"
$LGREEN = "$ESC[92m"
$LYELLOW = "$ESC[93m"
$LBLUE = "$ESC[94m"
$LMAGENTA = "$ESC[95m"
$LCYAN = "$ESC[96m"
$LWHITE = "$ESC[97m"

# ── Icons ─────────────────────────────────────────────────────────────────────

$ICON_OK = "${LGREEN}${BOLD}[+]${RESET}"
$ICON_SKIP = "${GRAY}${BOLD}[~]${RESET}"
$ICON_FAIL = "${LRED}${BOLD}[x]${RESET}"
$ICON_WARN = "${LYELLOW}${BOLD}[!]${RESET}"
$ICON_UP = "${LBLUE}${BOLD}[^]${RESET}"

# ── Banner ────────────────────────────────────────────────────────────────────

function Write-Banner {
  $w = try { $Host.UI.RawUI.WindowSize.Width } catch { 80 }
  if (-not $w -or $w -lt 60) { $w = 80 }

  $art = @(
    "██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗",
    "██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝",
    "██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗",
    "██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║",
    "██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║",
    "╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
  )

  $inner = $w - 4
  $top = "  ${LCYAN}╔$('═' * $inner)╗${RESET}"
  $bot = "  ${LCYAN}╚$('═' * $inner)╝${RESET}"
  $empty = "  ${LCYAN}║$(' ' * $inner)║${RESET}"

  Write-Host ''
  Write-Host $top
  Write-Host $empty

  foreach ($line in $art) {
    $pad = [math]::Max(0, [math]::Floor(($inner - $line.Length) / 2))
    $rest = $inner - $pad - $line.Length
    Write-Host "  ${LCYAN}║${RESET}$(' ' * $pad)${BOLD}${LWHITE}$line${RESET}$(' ' * $rest)${LCYAN}║${RESET}"
  }

  $sub = 'windows dotfiles  ·  github.com/sayidrahmatulloh/win-dotfiles'
  $sp = [math]::Max(0, [math]::Floor(($inner - $sub.Length) / 2))
  $sr = $inner - $sp - $sub.Length

  Write-Host $empty
  Write-Host "  ${LCYAN}║${RESET}$(' ' * $sp)${GRAY}$sub${RESET}$(' ' * $sr)${LCYAN}║${RESET}"
  Write-Host $empty
  Write-Host $bot
  Write-Host ''
}

# ── Section / Stage headers ───────────────────────────────────────────────────

function Write-Stage {
  param([string]$Icon, [string]$Title)
  Write-Host ''
  Write-Host "  ${BOLD}${LCYAN}==>  $Icon  $Title${RESET}"
  Write-Host "  ${GRAY}$('─' * 50)${RESET}"
}

function Write-Section {
  param([string]$Title)
  Write-Host ''
  Write-Host "  ${BOLD}${LWHITE}$Title${RESET}"
}

# ── Step indicator (inline — overwritten by Write-Done/Skip/Fail) ─────────────

function Write-Step {
  param([string]$Prefix, [string]$Name, [string]$Action)
  $colour = switch ($Action) {
    'installing' { $LMAGENTA }
    'upgrading' { $LBLUE }
    'adding' { $LYELLOW }
    'extracting' { $LCYAN }
    default { $GRAY }
  }
  Write-Host -NoNewline "  ${GRAY}$Prefix${RESET}  ${LWHITE}${BOLD}$Name${RESET}  ${colour}$Action${RESET}..."
}

# ── Status lines ──────────────────────────────────────────────────────────────

function Write-Done {
  param([string]$Msg)
  Write-Host "`r  $ICON_OK  ${LWHITE}$Msg${RESET}                    "
}

function Write-Skip {
  param([string]$Msg)
  Write-Host "`r  $ICON_SKIP  ${GRAY}$Msg${RESET}                    "
}

function Write-Fail {
  param([string]$Msg)
  Write-Host "`r  $ICON_FAIL  ${LRED}$Msg${RESET}                    "
}

function Write-Warn {
  param([string]$Msg)
  Write-Host "  $ICON_WARN  ${LYELLOW}$Msg${RESET}"
}

# ── Summary box ───────────────────────────────────────────────────────────────

function Write-Summary {
  param([string]$Label, [hashtable]$R)

  $installed = $R.Installed.Count
  $upgraded = if ($R.ContainsKey('Upgraded')) { $R.Upgraded.Count } else { 0 }
  $latest = if ($R.ContainsKey('Latest')) { $R.Latest.Count } else { 0 }
  $failed = $R.Failed.Count
  $width = [math]::Max(0, 32 - $Label.Length)

  Write-Host ''
  Write-Host "  ${LCYAN}┌─ ${BOLD}${LWHITE}$Label Summary${RESET}${LCYAN} $('─' * $width)┐${RESET}"

  if ($installed -gt 0) {
    Write-Host "  ${LCYAN}│${RESET}  $ICON_OK   ${LGREEN}Installed${RESET}   $installed"
  }
  if ($upgraded -gt 0) {
    Write-Host "  ${LCYAN}│${RESET}  $ICON_UP   ${LBLUE}Upgraded${RESET}    $upgraded"
  }
  if ($latest -gt 0) {
    Write-Host "  ${LCYAN}│${RESET}  $ICON_SKIP  ${GRAY}Up to date${RESET}  $latest"
  }
  if ($failed -gt 0) {
    Write-Host "  ${LCYAN}│${RESET}  $ICON_FAIL  ${LRED}Failed${RESET}      $failed"
    foreach ($item in $R.Failed) {
      Write-Host "  ${LCYAN}│${RESET}       ${GRAY}· $item${RESET}"
    }
  }
  if ($installed -eq 0 -and $upgraded -eq 0 -and $failed -eq 0) {
    Write-Host "  ${LCYAN}│${RESET}  $ICON_SKIP  ${GRAY}Nothing to do — all up to date${RESET}"
  }

  Write-Host "  ${LCYAN}└$('─' * 36)┘${RESET}"
  Write-Host ''
}
