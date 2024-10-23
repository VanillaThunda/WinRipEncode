$watchFolder = "D:\Ripping\03_Handbrake-working"
$outputFolder = "D:\Ripping\04_Handbrake-done"


# Action, wenn Datei hinzugefügt oder geändert wird
$action = {
    param($source, $eventArgs)

    Write-Host "action gestartet..." -ForegroundColor Cyan
    $handbrakePresetFile = "C:\Users\Valentin\Documents\Handbrake\Handbrake_Preset_V1.json"
    $handbrakePresetName = "NVENC Audio Passthru"
    $handBrakeCLI = "C:\Program Files\HandBrake_CLI\HandBrakeCLI.exe"

    $filePath = $eventArgs.FullPath
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $outputFile = "$outputFolder\$fileName.mkv"

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

    # Warten, bis die Datei fertig geschrieben wurde
    Write-Host ">>> Neue Datei entdeckt: '$filePath'" -ForegroundColor Green
    Wait-ForFileCompletion $filePath
    Write-Host ">>> Datei ist vollstaendig, starte Transcoding..." -ForegroundColor Green

    # HandBrakeCLI Befehl starten
    & $handBrakeCLI -i $filePath -o $outputFile --preset-import-file $handbrakePresetFile -Z $handbrakePresetName

    Write-Host ">>> Transcoding abgeschlossen: '$outputFile'" -ForegroundColor Green

    # Quelldatei löschen
    Remove-Item $filePath -Force
    Write-Host ">>> Quelldatei gelöscht: '$filePath'" -ForegroundColor Red
    Write-Host "---------------------------------" -ForegroundColor Magenta
}

# Überwachungsobjekt erstellen
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchFolder
$watcher.Filter = "*.mkv"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'
$watcher.EnableRaisingEvents = $true

# Eventhandler für das Erstellen und Ändern einer Datei
Register-ObjectEvent $watcher "Changed" -Action $action

# Die Schleife hält das Skript am Laufen
while ($true) {
    Start-Sleep -Seconds 5
}
