$watchFolder = "D:\Ripping\03_Handbrake-working"

# Logdatei definieren
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "D:\Ripping\98_AutoRip-Logs\Handbrake\handbrake_$timestamp.log"
Start-Transcript -Path $logFile -Append

Write-Host "-----------------------------------------" -ForegroundColor Magenta
Write-Host "----------Valentins Auto-Ripper----------" -ForegroundColor Cyan
Write-Host "-----------------------------------------" -ForegroundColor Magenta

# Log current date and time
Write-Host (Get-Date) -ForegroundColor Magenta

################################################################

# Action, wenn Datei hinzugefügt oder geändert wird
$action = {
    param($source, $eventArgs)

    Write-Host ">>> action gestartet..." -ForegroundColor Cyan
    $handbrakePresetFile = "C:\Users\Valentin\Documents\Handbrake\Handbrake_Preset_V1.json"
    $handbrakePresetName = "NVENC Audio Passthru"
    $handBrakeCLI = "C:\Program Files\HandBrake_CLI\HandBrakeCLI.exe"
    $outputFolder = "D:\Ripping\04_Handbrake-done"

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

    # HandBrakeCLI Befehl starten und Ausgabe durchleiten
    $process = Start-Process -FilePath $handBrakeCLI -ArgumentList "-i `"$filePath`" -o `"$outputFile`" --preset-import-file `"$handbrakePresetFile`" -Z `"$handbrakePresetName`"" -NoNewWindow -Wait -PassThru

    # Warten, bis der Prozess abgeschlossen ist
    Wait-Process -Id $process.Id

    Write-Host ">>> Transcoding abgeschlossen: '$outputFile'" -ForegroundColor Green

    # Quelldatei löschen
    Remove-Item $filePath -Force
    Write-Host ">>> Quelldatei geloescht: '$filePath'" -ForegroundColor Yellow
    Write-Host "---------------------------------" -ForegroundColor Magenta
}

# Überwachungsobjekt erstellen
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchFolder
$watcher.Filter = "*.mkv"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'
$watcher.EnableRaisingEvents = $true

# Eventhandler für das Erstellen einer Datei (nur einmal ausführen)
Register-ObjectEvent $watcher "Created" -Action $action

# Die Schleife hält das Skript am Laufen
while ($true) {
    Start-Sleep -Seconds 5
}

# Stop logging
Stop-Transcript