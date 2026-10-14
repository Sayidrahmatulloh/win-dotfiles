# Run with Windows PowerShell 5.1 in STA mode. No admin rights required.
param([switch]$SetupOnly, [switch]$Preview, [switch]$SelfTest, [ValidateRange(0,30)][int]$StartupDelaySeconds = 0)
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -eq 'Core') {
    # Windows Forms compilation uses the built-in .NET Framework host.
    $hostArguments = @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',$PSCommandPath)
    foreach ($entry in $PSBoundParameters.GetEnumerator()) {
        if ($entry.Value -is [Management.Automation.SwitchParameter]) {
            if ($entry.Value.IsPresent) { $hostArguments += ('-' + $entry.Key) }
        } else {
            $hostArguments += @('-' + $entry.Key, [string]$entry.Value)
        }
    }
    & "$env:WINDIR/System32/WindowsPowerShell/v1.0/powershell.exe" @hostArguments
    if ($LASTEXITCODE -ne 0) { throw "Walnut lock host failed (exit $LASTEXITCODE)." }
    return
}
Add-Type -AssemblyName System.Windows.Forms, System.Drawing, System.Security
Add-Type -Path "$PSScriptRoot/KeyboardHook.cs"
Add-Type -Path "$PSScriptRoot/Overlay.cs" -ReferencedAssemblies System.Windows.Forms,System.Drawing
[WalnutKeys]::UsePhysicalPixels()
$store = Join-Path $env:LOCALAPPDATA 'WalnutLock/credential.dat'

function Set-WidgetFolded([bool]$Hidden) {
    $repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $state = @{hidden=$Hidden; revision=[DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()} | ConvertTo-Json -Compress
    foreach ($folder in @('walnut-keyboard','walnut-laptop')) {
        $path = Join-Path $repo "widgets/zebar/$folder/lock-state.json"
        [IO.File]::WriteAllText($path,$state)
    }
}

function Get-CodeHash([string]$Code, [byte[]]$Salt) {
    $derive = [Security.Cryptography.Rfc2898DeriveBytes]::new($Code, $Salt, 100000)
    try { return [Convert]::ToBase64String($derive.GetBytes(32)) } finally { $derive.Dispose() }
}
function Read-Credential {
    if (-not (Test-Path -LiteralPath $store)) { return $null }
    $bytes = [IO.File]::ReadAllBytes($store)
    $plain = [Security.Cryptography.ProtectedData]::Unprotect($bytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
    return [Text.Encoding]::UTF8.GetString($plain) | ConvertFrom-Json
}
function Save-Credential([string]$Code) {
    $salt = New-Object byte[] 24
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($salt) } finally { $rng.Dispose() }
    $record = @{ salt=[Convert]::ToBase64String($salt); hash=(Get-CodeHash $Code $salt) } | ConvertTo-Json -Compress
    $bytes = [Security.Cryptography.ProtectedData]::Protect([Text.Encoding]::UTF8.GetBytes($record), $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
    [IO.Directory]::CreateDirectory((Split-Path $store)) | Out-Null
    [IO.File]::WriteAllBytes($store, $bytes)
}

function New-Panel([string]$Title) {
    $form = New-Object Windows.Forms.Form
    $form.Text = $Title
    $form.ClientSize = [Drawing.Size]::new(720,390)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [Drawing.Color]::FromArgb(16,22,25)
    $form.ForeColor = [Drawing.Color]::FromArgb(237,215,176)
    $form.Font = [Drawing.Font]::new('Segoe UI',11)
    $name = New-Object Windows.Forms.Label
    $name.Text = 'Sayidrahmatulloh'
    $name.Font = [Drawing.Font]::new('Palatino Linotype',36,[Drawing.FontStyle]::Italic)
    $name.TextAlign = 'MiddleCenter'
    $name.SetBounds(0,50,720,85)
    $form.Controls.Add($name)
    return $form
}

if ($SelfTest) {
    foreach ($key in @(9,16,17,18,20,91,92,112,123,160,165)) {
        if (-not [WalnutKeys]::IsBlockedKey($key)) { throw "Key $key should be blocked." }
    }
    foreach ($key in @(32,8,13,65,90,48,57,186,190,37,39)) {
        if ([WalnutKeys]::IsBlockedKey($key)) { throw "Text key $key should remain usable." }
    }
    $salt = New-Object byte[] 24
    $one = Get-CodeHash 'TestOnly123' $salt
    $two = Get-CodeHash 'TestOnly123' $salt
    $wrong = Get-CodeHash 'WrongCode123' $salt
    if ($one -cne $two -or $one -ceq $wrong) { throw 'Code hashing failed.' }
    $bytes = [Text.Encoding]::UTF8.GetBytes($one)
    $sealed = [Security.Cryptography.ProtectedData]::Protect($bytes,$null,[Security.Cryptography.DataProtectionScope]::CurrentUser)
    $opened = [Security.Cryptography.ProtectedData]::Unprotect($sealed,$null,[Security.Cryptography.DataProtectionScope]::CurrentUser)
    if ([Text.Encoding]::UTF8.GetString($opened) -cne $one) { throw 'Credential encryption failed.' }
    $testForm = New-Panel 'Test'
    $testForm.Dispose()
    $testOverlay = New-Object WalnutOverlay
    $testOverlay.Dispose()
    Write-Host 'Code validation, encryption, UI construction and hook compilation passed. No lock installed.'
    return
}
$created = $false
$instanceMutex = [Threading.Mutex]::new($false, ('Local\WalnutLock-' + $env:USERNAME), [ref]$created)
if (-not $created) { $instanceMutex.Dispose(); return }
$credential = Read-Credential
if (-not $credential -or $SetupOnly) {
    $setup = New-Panel 'Walnut — yangi kod yaratish'
    $hint = New-Object Windows.Forms.Label
    $hint.Text = 'Yangi kod yarating (kamida 6 ta harf yoki raqam)'
    $hint.TextAlign = 'MiddleCenter'; $hint.SetBounds(30,145,660,28)
    $first = New-Object Windows.Forms.TextBox
    $first.UseSystemPasswordChar = $true; $first.SetBounds(220,185,280,28)
    $second = New-Object Windows.Forms.TextBox
    $second.UseSystemPasswordChar = $true; $second.SetBounds(220,225,280,28)
    $second.AccessibleName = 'Kodni qayta kiriting'
    $save = New-Object Windows.Forms.Button
    $save.Text = 'Saqlash'; $save.SetBounds(290,275,140,36)
    $setup.Controls.AddRange(@($hint,$first,$second,$save))
    $setup.AcceptButton = $save
    $script:saved = $false
    $save.Add_Click({
        if ($first.Text -notmatch '^[A-Za-z0-9]{6,64}$') { $hint.Text='Kod 6–64 ta lotin harfi yoki raqamdan iborat boʻlsin.'; return }
        if ($first.Text -cne $second.Text) { $hint.Text='Kodlar bir xil emas. Qayta kiriting.'; return }
        Save-Credential $first.Text
        $script:saved = $true
        $setup.Close()
    })
    [void]$setup.ShowDialog()
    $setup.Dispose()
    # Setup never automatically locks you out: run again to try the lock.
    if ($script:saved) { Write-Host 'Kod saqlandi. Sinash uchun skriptni yana ishga tushiring.' }
    return
}

if ($StartupDelaySeconds -gt 0) {
    Start-Sleep -Seconds $StartupDelaySeconds
    Set-WidgetFolded $false
    Start-Sleep -Milliseconds 800
}
# Capture the current desktop into memory only. The input shield looks identical
# to the existing laptop/keyboard widgets, but receives all ordinary input.
function New-DesktopImage($Bounds) {
    $bitmap = [Drawing.Bitmap]::new($Bounds.Width, $Bounds.Height)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($Bounds.Location, [Drawing.Point]::Empty, $Bounds.Size)
        return $bitmap
    } catch {
        $bitmap.Dispose()
        throw
    } finally { $graphics.Dispose() }
}

$form = New-Object WalnutOverlay
$form.AutoScaleMode = 'None'
$form.Text = 'Walnut — invisible code entry'
$form.FormBorderStyle = 'None'
$form.StartPosition = 'Manual'
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.Bounds = [Windows.Forms.Screen]::PrimaryScreen.Bounds
$form.BackgroundImage = New-DesktopImage $form.Bounds
$form.BackgroundImageLayout = 'None'
# Remains focusable while placed outside the visible client area. No stars/caret.
$codeInput = New-Object Windows.Forms.TextBox
$codeInput.UseSystemPasswordChar = $true
$codeInput.SetBounds(-2000, -2000, 100, 30)
$codeInput.MaxLength = 64
$form.Controls.Add($codeInput)
$form.Add_MouseDown({ [void]$codeInput.Focus() })
$others = @()
foreach ($screen in [Windows.Forms.Screen]::AllScreens) {
    if ($screen.Primary) { continue }
    $cover = New-Object WalnutOverlay
    $cover.Text = 'Walnut — invisible code entry'
    $cover.AutoScaleMode = 'None'
    $cover.FormBorderStyle = 'None'
    $cover.StartPosition = 'Manual'
    $cover.TopMost = $true
    $cover.Bounds = $screen.Bounds
    $cover.BackgroundImage = New-DesktopImage $screen.Bounds
    $cover.BackgroundImageLayout = 'None'
    $cover.ShowInTaskbar = $false
    $cover.Add_MouseDown({ $form.Activate(); [void]$codeInput.Focus() })
    $others += $cover
}
$script:unlocked = $false
$script:releaseTicks = 0
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 200
$timer.Add_Tick({
    if ($script:unlocked) {
        if ([WalnutKeys]::InputReleased) { $script:releaseTicks++ } else { $script:releaseTicks = 0 }
        if ($script:releaseTicks -ge 2) {
            $timer.Stop()
            $form.Close()
        }
        return
    }
    if (-not $script:unlocked -and -not $Preview) {
        $form.Activate()
        [void]$codeInput.Focus()
    }
})
$codeInput.Add_KeyDown({
    if ($_.KeyCode -ne 'Enter') { return }
    $_.SuppressKeyPress = $true
    try {
        $salt = [Convert]::FromBase64String($credential.salt)
        $candidate = Get-CodeHash $codeInput.Text $salt
        $codeInput.Clear()
        if ($candidate -cne $credential.hash) {
            # No error label: clear the buffer and allow another attempt.
            [Media.SystemSounds]::Beep.Play()
            return
        }
        $script:unlocked = $true
        # Keep both hooks and all covers until the unlocking Enter/click is released.
        [WalnutKeys]::BeginDrain()
    } catch {
        [WalnutKeys]::Stop()
        $timer.Stop()
        $form.Close()
        [void][Windows.Forms.MessageBox]::Show('Tekshiruvda xatolik yuz berdi. Bloklash oʻchirildi.','Walnut')
    }
})
$form.Add_Shown({ [void]$codeInput.Focus(); $timer.Start() })
try {
    foreach ($cover in $others) { $cover.Show() }
    if (-not $Preview) { [WalnutKeys]::Start() }
    [void]$form.ShowDialog()
} finally {
    [WalnutKeys]::Stop()
    $timer.Stop()
    $timer.Dispose()
    foreach ($cover in $others) {
        $cover.Close()
        $cover.BackgroundImage.Dispose()
        $cover.Dispose()
    }
    $form.BackgroundImage.Dispose()
    $form.Dispose()
}
