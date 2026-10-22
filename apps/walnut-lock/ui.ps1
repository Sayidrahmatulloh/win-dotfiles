# Window construction and desktop images; no keyboard hooks are installed here.
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
function New-DesktopOverlay {
    param([Windows.Forms.Screen]$Screen)
    $overlay = New-Object WalnutOverlay
    $overlay.AutoScaleMode = 'None'
    $overlay.Text = 'Walnut — invisible code entry'
    $overlay.FormBorderStyle = 'None'
    $overlay.StartPosition = 'Manual'
    $overlay.TopMost = $true
    $overlay.ShowInTaskbar = $false
    $overlay.Bounds = $Screen.Bounds
    $overlay.BackgroundImage = New-DesktopImage $Screen.Bounds
    $overlay.BackgroundImageLayout = 'None'
    return $overlay
}
