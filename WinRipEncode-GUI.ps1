Add-Type -AssemblyName System.Windows.Forms

# Formular erstellen
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell GUI mit Status"
$form.Size = New-Object System.Drawing.Size(400, 200)

# Label für Statusanzeige neben Button1 (Rot: inaktiv, Grün: aktiv)
$statusLabel1 = New-Object System.Windows.Forms.Label
$statusLabel1.Location = New-Object System.Drawing.Point(270, 50)
$statusLabel1.Size = New-Object System.Drawing.Size(80, 30)
$statusLabel1.BackColor = 'Red'  # Rot für inaktiv
$statusLabel1.Text = 'Stopped'

# Button 1 erstellen
$button1 = New-Object System.Windows.Forms.Button
$button1.Location = New-Object System.Drawing.Point(50, 50)
$button1.Size = New-Object System.Drawing.Size(200, 30)
$button1.Text = "Skript 1 ausführen"

# Label für Statusanzeige neben Button2 (Rot: inaktiv, Grün: aktiv)
$statusLabel2 = New-Object System.Windows.Forms.Label
$statusLabel2.Location = New-Object System.Drawing.Point(270, 100)
$statusLabel2.Size = New-Object System.Drawing.Size(80, 30)
$statusLabel2.BackColor = 'Red'  # Rot für inaktiv
$statusLabel2.Text = 'Stopped'

# Button 2 erstellen
$button2 = New-Object System.Windows.Forms.Button
$button2.Location = New-Object System.Drawing.Point(50, 100)
$button2.Size = New-Object System.Drawing.Size(200, 30)
$button2.Text = "Skript 2 ausführen"

# Funktion zur Ausführung des Skripts mit Statusänderung
function Start-Script {
    param ($scriptPath, $statusLabel)

    # Status auf "Grün" setzen (aktiv)
    $statusLabel.BackColor = 'Green'
    $statusLabel.Text = 'Running'

    # Skript in einem Hintergrundjob ausführen
    $job = Start-Job -ScriptBlock {
        param ($scriptPath)
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Wait
    } -ArgumentList $scriptPath

    # Warten, bis der Job fertig ist
    $null = Wait-Job $job

    # Status auf "Rot" setzen (inaktiv)
    $statusLabel.BackColor = 'Red'
    $statusLabel.Text = 'Stopped'

    # Job entfernen
    Remove-Job $job
}

# Ereignis-Handler für Button 1
$button1.Add_Click({
    $scriptPath1 = "M:\Technik\Programmieren\Ripping-PC\Disc-1-Movie-1.ps1"
    Start-Script -scriptPath $scriptPath1 -statusLabel $statusLabel1
})

# Ereignis-Handler für Button 2
$button2.Add_Click({
    $scriptPath2 = "C:\Pfad\zu\deinem\Skript2.ps1"
    Start-Script -scriptPath $scriptPath2 -statusLabel $statusLabel2
})

# Steuerelemente zum Formular hinzufügen
$form.Controls.Add($button1)
$form.Controls.Add($statusLabel1)
$form.Controls.Add($button2)
$form.Controls.Add($statusLabel2)

# Formular anzeigen
$form.ShowDialog()
