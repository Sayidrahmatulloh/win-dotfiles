# Console formatting only. No setup actions run when loaded.
function Write-InstallResult {
    param($Entry)
    switch ($Entry.Status) {
        Installed {
            Write-Done "installed: $($Entry.Name)"
            if ($Entry.BackupPath) { Write-Warn "Previous configuration retained: $($Entry.BackupPath)" }
        }
        Upgraded { Write-Done "upgraded: $($Entry.Name)" }
        Latest { Write-Skip "$($Entry.Message): $($Entry.Name)" }
        Failed {
            Write-Fail "$($Entry.Name) : $($Entry.Message)"
            if ($Entry.RollbackError) { Write-Fail "Rollback failed: $($Entry.RollbackError). Recover from: $($Entry.BackupPath)" }
        }
    }
}

# ============================================================
#  lib/core/output.ps1 — Console formatting helpers for dotfiles scripts
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
  param([string]$Label, $R)

  $installed = $R.Installed.Count
  $upgraded = $R.Upgraded.Count
  $latest = $R.Latest.Count
  $failed = $R.Failed.Count
  $title = "$Label Summary"
  $rows = [Collections.Generic.List[string]]::new()
  foreach ($status in @(
    @{Count=$installed; Icon=$ICON_OK; Name='Installed'; Color=$LGREEN},
    @{Count=$upgraded; Icon=$ICON_UP; Name='Upgraded'; Color=$LBLUE},
    @{Count=$latest; Icon=$ICON_SKIP; Name='Up to date'; Color=$GRAY},
    @{Count=$failed; Icon=$ICON_FAIL; Name='Failed'; Color=$LRED}
  )) {
    if ($status.Count -gt 0) {
      $text = '{0,-12} {1,4}' -f $status.Name, $status.Count
      $rows.Add("$($status.Icon)  $($status.Color)$text${RESET}")
    }
  }
  if ($rows.Count -eq 0) { $rows.Add("${GRAY}No packages to process.${RESET}") }

  # One width for every edge; ANSI escapes do not occupy terminal columns.
  $ansi = '\x1b\[[0-9;]*m'
  $terminalWidth = try { $Host.UI.RawUI.WindowSize.Width } catch { 80 }
  if ($terminalWidth -le 0) { $terminalWidth = 80 }
  $inner = [math]::Min([math]::Max(34, $title.Length + 4), [math]::Max(8, $terminalWidth - 4))
  $contentWidth = $inner - 4
  function Write-SummaryLine {
    param([string]$Text)
    $plain = $Text -replace $ansi, ''
    if ($plain.Length -le $contentWidth) {
      $padding = ' ' * ($contentWidth - $plain.Length)
      Write-Host "  ${LCYAN}│${RESET}  $Text$padding  ${LCYAN}│${RESET}"
      return
    }
    # Wrap long labels and failed package names instead of overflowing the box.
    for ($offset = 0; $offset -lt $plain.Length; $offset += $contentWidth) {
      $part = $plain.Substring($offset, [math]::Min($contentWidth, $plain.Length - $offset))
      $padding = ' ' * ($contentWidth - $part.Length)
      Write-Host "  ${LCYAN}│${RESET}  ${GRAY}$part${RESET}$padding  ${LCYAN}│${RESET}"
    }
  }

  Write-Host ''
  Write-Host "  ${LCYAN}╭$('─' * $inner)╮${RESET}"
  Write-SummaryLine "${BOLD}${LWHITE}$title${RESET}"
  Write-Host "  ${LCYAN}├$('─' * $inner)┤${RESET}"
  foreach ($row in $rows) { Write-SummaryLine $row }
  if ($failed -gt 0) {
    Write-SummaryLine ''
    foreach ($item in $R.Failed) { Write-SummaryLine "${LRED}· $item${RESET}" }
  }
  Write-Host "  ${LCYAN}╰$('─' * $inner)╯${RESET}"
  Write-Host ''
}
