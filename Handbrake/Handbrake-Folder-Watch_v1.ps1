$watchFolder = "D:\Ripping\03_Handbrake-working"
$outputFolder = "D:\Ripping\04_Handbrake-done"
$handbrakePresetFile = "C:\Users\Valentin\Documents\Handbrake\Handbrake_Preset_V1.json"
$handbrakePresetName = "NVENC Audio Passthru"

# HandBrakeCLI Pfad
$handBrakeCLI = "C:\Program Files\HandBrake_CLI\HandBrakeCLI.exe"

# Filter auf überwachten Ordner
$filter = "*.mkv"

# Action, wenn Datei hinzugefügt wird
$action = {
    param($source, $filePath)
    
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $outputFile = "$outputFolder\$fileName.mkv"

    Write-Host ">>> Neue Datei entdeckt: $filePath" -ForegroundColor Green

    # HandBrakeCLI Befehl starten
    # & $handBrakeCLI -i $filePath -o $outputFile --preset "Fast 1080p30"
    & $HandBrakeCLI -i $filePath -o $outputFile --preset-import-file $handbrakePresetFile -Z $handbrakePresetName

    Write-Host ">>> Transcoding abgeschlossen: $outputFile" -ForegroundColor Green
}

# Überwachungsobjekt erstellen
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchFolder
$watcher.Filter = $filter
$watcher.EnableRaisingEvents = $true

# Eventhandler für das Erstellen einer Datei
Register-ObjectEvent $watcher "Created" -Action $action

# Die Schleife hält das Skript am Laufen
while ($true) {
    Start-Sleep -Seconds 10
}
