Add-Type -AssemblyName System.Windows.Forms

# Formular erstellen
$form = New-Object System.Windows.Forms.Form
$form.Text = "WinRipEncode"
$form.Size = New-Object System.Drawing.Size(300, 300)

# Button 1 erstellen
$button1 = New-Object System.Windows.Forms.Button
$button1.Location = New-Object System.Drawing.Point(50, 50)
$button1.Size = New-Object System.Drawing.Size(200, 30)
$button1.Text = "1. Start MakeMKV-Auto-Rip"

# Button 2 erstellen
$button2 = New-Object System.Windows.Forms.Button
$button2.Location = New-Object System.Drawing.Point(50, 100)
$button2.Size = New-Object System.Drawing.Size(200, 30)
$button2.Text = "2. Start Handbrake Watcher"

# Button 3 erstellen
$button3 = New-Object System.Windows.Forms.Button
$button3.Location = New-Object System.Drawing.Point(50, 150)
$button3.Size = New-Object System.Drawing.Size(200, 30)
$button3.Text = "3. Start Filebot Auto-Rename"

# Button 4 erstellen
$button4 = New-Object System.Windows.Forms.Button
$button4.Location = New-Object System.Drawing.Point(50, 200)
$button4.Size = New-Object System.Drawing.Size(200, 30)
$button4.Text = "4. Start Copy Movies"

# Ereignis-Handler für Button 1
$button1.Add_Click({
    $scriptPath1 = "C:\Users\Valentin\Documents\GitHub\WinRipEncode\MakeMKV\MakeMKV-Auto-Rip.ps1"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$scriptPath1`""
})

# Ereignis-Handler für Button 2
$button2.Add_Click({
    $scriptPath2 = "C:\Users\Valentin\Documents\GitHub\WinRipEncode\Handbrake\Handbrake-Folder-Watch.ps1"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$scriptPath2`""
})

# Ereignis-Handler für Button 3
$button3.Add_Click({
    $scriptPath3 = "C:\Users\Valentin\Documents\GitHub\WinRipEncode\FileBot\FileBot-Folder-Watch.ps1"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$scriptPath3`""
})

# Ereignis-Handler für Button 3
$button4.Add_Click({
    $scriptPath4 = "C:\Users\Valentin\Documents\GitHub\WinRipEncode\Robocopy\Copy-Movies.ps1"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$scriptPath4`""
})

# Buttons zum Formular hinzufügen
$form.Controls.Add($button1)
$form.Controls.Add($button2)
$form.Controls.Add($button3)
$form.Controls.Add($button4)

# Formular anzeigen
$form.ShowDialog()
