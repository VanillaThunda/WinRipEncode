$watchFolder = "D:\Ripping\03_Handbrake-working"

# Logdatei definieren
$timestamp = Get-Date -Format "yyyy-MM-dd"
$logFile = "D:\Ripping\98_AutoRip-Logs\Handbrake\handbrake_$timestamp.log"
Start-Transcript -Path $logFile -Append

Write-Host "----------------------------------------" -ForegroundColor Magenta
Write-Host "--------------WinRipEncode--------------" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Magenta

# Log current date and time
Write-Host (Get-Date) -ForegroundColor Magenta

################################################################

# Action, wenn Datei hinzugefügt oder geändert wird
$action = {
    param($source, $eventArgs)

    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> action gestartet..." -ForegroundColor Cyan
    $handbrakePresetFile = "C:\Users\Valentin\Documents\Handbrake\Handbrake_Preset_V1.json"
    $handbrakePresetName = "NVENC Audio Passthru"
    $handBrakeCLI = "C:\Program Files\HandBrake_CLI\HandBrakeCLI.exe"
    $outputFolder = "D:\Ripping\04_Handbrake-done"

    $filePath = $eventArgs.FullPath
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $outputFile = "$outputFolder\$fileName.mkv"

    # Funktion, um zu prüfen, ob die Datei noch von einem anderen Prozess verwendet wird
    function Wait-ForFileCompletion {
        param (
            [string]$filePath,
            [int]$waitTimeInSeconds = 5
        )

        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Warte darauf, dass die Datei freigegeben wird..." -ForegroundColor Cyan

        $fileLocked = $true

        while ($fileLocked) {
            try {
                # Versuche die Datei zu öffnen (exklusiver Zugriff)
                $fileStream = [System.IO.File]::Open($filePath, 'Open', 'Read', 'ReadWrite')
                $fileStream.Close()
                
                # Wenn das Öffnen erfolgreich ist, gilt die Datei als freigegeben
                $fileLocked = $false
            } catch {
                # Falls ein Fehler auftritt, wird davon ausgegangen, dass die Datei noch gesperrt ist
                Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Datei wird noch verwendet, warte..." -ForegroundColor Yellow
            }

            # Warte eine Weile, bevor der nächste Versuch gestartet wird
            Start-Sleep -Seconds $waitTimeInSeconds
        }

        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Datei ist jetzt freigegeben." -ForegroundColor Green
    }

    # Warten, bis die Datei fertig geschrieben wurde
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Neue Datei entdeckt: '$filePath'" -ForegroundColor Green
    Wait-ForFileCompletion $filePath
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Starte Transcoding..." -ForegroundColor Green

    # HandBrakeCLI Befehl starten und Ausgabe durchleiten
    $process = Start-Process -FilePath $handBrakeCLI -ArgumentList "-i `"$filePath`" -o `"$outputFile`" --preset-import-file `"$handbrakePresetFile`" -Z `"$handbrakePresetName`"" -NoNewWindow -Wait -PassThru

    # Warten, bis der Prozess abgeschlossen ist
    Wait-Process -Id $process.Id

    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Transcoding abgeschlossen: '$outputFile'" -ForegroundColor Green

    # Quelldatei löschen
    Remove-Item $filePath -Force
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Quelldatei geloescht: '$filePath'" -ForegroundColor Yellow
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