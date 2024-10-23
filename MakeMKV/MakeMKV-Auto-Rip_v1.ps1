# Inspiration from: https://gist.github.com/tacofumi/3041eac2f59da7a775c6
# Verzeichnis von MakeMKV
$makemkvDir = "C:\Program Files (x86)\MakeMKV"

# Ausgabeverzeichnis der rohen MKV-Dateien
$workingDir = "D:\Ripping\01_MakeMKV-working"

# Ausgabeverzeichnis der fertigen MKV-Datei
$doneDir = "D:\Ripping\02_MakeMKV-done"

# Datei um die Infos um den Titel zu erhalten zwischenzuspeichern
$rawTitleFile = "D:\Ripping\98_AutoRip-Logs\title-raw.txt"

# Buchstabe zum Laufwerk
$discletter = "E:"

# Suchbegriffe vor und nach dem Title um diesen zu extrahieren
$searchBeforeTitle = "BD-RE HL-DT-ST BD-RE BU40N 1\.03 7MEQVHAKKGZ012"
$searchAfterTitle = "E:"

# '--minlength' Parameter fpr MakeMKV (Default from MakeMKV is 120 Sec.)
$minlength = "240"

# ----------------------------------------------------

# Logdatei definieren
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "D:\Ripping\98_AutoRip-Logs\MakeMKV\MakeMKV_$timestamp.log"
Start-Transcript -Path $logFile -Append

Write-Host "----------------------------------------" -ForegroundColor Magenta
Write-Host "--------------WinRipEncode--------------" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Magenta

# Log current date and time
Write-Host (Get-Date) -ForegroundColor Magenta

Write-Host ">>> Durchsuche die Disk..." -ForegroundColor Green
# MakeMKV Info starten um den Titel herauszufinden -> Schreibe den Output in eine txt Datei um diese per Regex zu durchsuchen und den Titel zu finden
& "$makemkvDir\makemkvcon.exe" -r info | Out-File -FilePath "$rawTitleFile"

# Überprüfen, ob die Datei existiert
if (Test-Path $rawTitleFile) {
    # Dateiinhalt einlesen
    $titleContent = Get-Content $rawTitleFile -Raw

    # Gib den eingelesenen Inhalt zur Überprüfung aus (optional)
    Write-Host ">>> Inhalt der Datei: `n$titleContent" -ForegroundColor Cyan

    # Dynamischer Aufbau des regulären Ausdrucks mit den Variablen
    $regex = '"' + $searchBeforeTitle + '","([^"]+)","' + $searchAfterTitle + '"'
    Write-Host ">>> Regex = $regex" -ForegroundColor Green

    # Verwende den regulären Ausdruck, um den Titel zwischen den konstanten Werten zu extrahieren
    if ($titleContent -match $regex) {
        # Speichere den gefundenen Titel in $foundtitle
        $foundtitle = $Matches[1]
        Write-Host ">>> Gefundener Titel: '$foundtitle'" -ForegroundColor Green
        $rawTitleFile | Remove-Item
    } else {
        # Falls kein Treffer gefunden wurde, gib eine Fehlermeldung aus
        Write-Host ">>> Kein gültiger Titel gefunden" -ForegroundColor Red
        $rawTitleFile | Remove-Item
        exit
    }
} else {
    Write-Host ">>> Die Datei '$rawTitleFile' wurde nicht gefunden." -ForegroundColor Red
}

Write-Host ">>> Ripping wird gestartet..." -ForegroundColor Green

# Execute makemkvcon for ripping (same logic as in Bash)
& "$makemkvDir\makemkvcon.exe" --minlength=$minlength -r --decrypt --directio=true mkv disc:0 all "$workingDir"

# Get all MKV files in the output directory
$mkvFiles = Get-ChildItem "$workingDir\*.mkv"
Get-ChildItem "$workingDir\*.mkv"

if ($mkvFiles.Count -gt 0) {
    # Find the largest MKV file and store only the name
    $largestFileName = ($mkvFiles | Sort-Object Length -Descending | Select-Object -First 1).Name
    Write-Host ">>> Biggest File: '$largestFileName'`n" -ForegroundColor Green

    # Move the largest MKV file and rename it with $foundtitle
    Move-Item -Path "$workingDir\$largestFileName" -Destination "$doneDir\$foundtitle.mkv"
    Write-Host ">>> '$workingDir\$largestFileName' wurde nach '$doneDir\$foundtitle.mkv' verschoben`n" -ForegroundColor Green

    # Rename the moved mkv file
    # Rename-Item -Path "$doneDir\$largestFileName" -NewName "$foundtitle.mkv"
    # Write-Host ">>> '$largestFileName' renamed in '$foundtitle.mkv'`n" -ForegroundColor Green

    # Delete the remaining MKV files (if any), ensuring the largest one is not deleted
    $mkvFiles | Where-Object { $_.Name -ne $largestFileName } | ForEach-Object {
        Remove-Item (Join-Path $workingDir $_.Name)
        Write-Host ">>> Deleted: $($_.Name)" -ForegroundColor Green
    }
} else {
    Write-Host ">>> Keine *.mkv Dateien in '$workingDir' gefunden" -ForegroundColor Red
    exit
}

# Eject the disk - PowerShell Version, not working for me:
# (New-Object -ComObject Shell.Application).Namespace(17).ParseName("$discletter\").InvokeVerb("Eject")

# Eject the disk - Windows Media Player must be installed for this to work
Write-Host ">>> Ejecting Drive..." -ForegroundColor Cyan
(New-Object -com "WMPlayer.OCX.7").cdromcollection.item(0).eject()

Write-Host ">>>Titel: '$foundtitle.mkv' wurde erstellt<<<" -ForegroundColor Green

# Stop logging
Stop-Transcript
