$watchFolder = "D:\Ripping\03_Handbrake-working"
$filter = "*.mkv"

# Funktion, um zu prüfen, ob eine Datei abgeschlossen ist
function Wait-ForFileCompletion {
    param (
        [string]$filePath,
        [int]$waitTimeInSeconds = 5
    )

    $previousSize = (Get-Item $filePath).Length
    Start-Sleep -Seconds $waitTimeInSeconds
    $currentSize = (Get-Item $filePath).Length

    while ($previousSize -ne $currentSize) {
        Write-Host ">>> Datei wird noch geschrieben, warte..." -ForegroundColor Yellow
        $previousSize = $currentSize
        Start-Sleep -Seconds $waitTimeInSeconds
        $currentSize = (Get-Item $filePath).Length
    }
}

# Action, wenn Datei hinzugefügt oder geändert wird
$action = {
    param($source, $eventArgs)

    $outputFolder = "D:\Ripping\04_Handbrake-done"
    $handbrakePresetFile = "C:\Users\Valentin\Documents\Handbrake\Handbrake_Preset_V1.json"
    $handbrakePresetName = "NVENC Audio Passthru"
    $handBrakeCLI = "C:\Program Files\HandBrake_CLI\HandBrakeCLI.exe"

    $filePath = $eventArgs.FullPath
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $outputFile = "$outputFolder\$fileName.mkv"

    # Warten, bis die Datei fertig geschrieben wurde
    Write-Host "`n>>> Neue Datei entdeckt: $filePath" -ForegroundColor Green
    Wait-ForFileCompletion $filePath
    Write-Host ">>> Datei ist vollständig, starte Transcoding..." -ForegroundColor Green

    # HandBrakeCLI Befehl starten
    & $handBrakeCLI -i $filePath -o $outputFile --preset-import-file $handbrakePresetFile -Z $handbrakePresetName

    Write-Host ">>> Transcoding abgeschlossen: '$outputFile'" -ForegroundColor Green
}

# Überwachungsobjekt erstellen
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchFolder
$watcher.Filter = $filter
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'
$watcher.EnableRaisingEvents = $true

# Eventhandler für das Erstellen und Ändern einer Datei
Register-ObjectEvent $watcher "Changed" -Action $action

# Die Schleife hält das Skript am Laufen
while ($true) {
    Start-Sleep -Seconds 10
}
