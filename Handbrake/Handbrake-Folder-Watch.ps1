$watchFolder = "D:\Ripping\02_MakeMKV-done"

# Define Logfile
$timestamp = Get-Date -Format "yyyy-MM-dd"
$logFile = "D:\Ripping\98_WinRipEncode-Logs\Handbrake\handbrake_$timestamp.log"
Start-Transcript -Path $logFile -Append

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "--------------WinRipEncode--------------" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# Log current date and time
Write-Host (Get-Date) -ForegroundColor Magenta

################################################################

# Action when file is created
$action = {
    param($source, $eventArgs)

    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> action started..." -ForegroundColor Cyan
    $handbrakePresetFile = "D:\Ripping\99_Other\Handbrake_Preset_V1.json"
    $handbrakePresetName = "NVENC Audio Passthru"
    $handBrakeCLI = "C:\Program Files\HandBrake_CLI\HandBrakeCLI.exe"
    $outputFolder = "D:\Ripping\04_Handbrake-done"

    $filePath = $eventArgs.FullPath
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $outputFile = "$outputFolder\$fileName.mkv"

    # Function to check whether the file is still being used by another process
    function Wait-ForFileCompletion {
        param (
            [string]$filePath,
            [int]$waitTimeInSeconds = 5
        )

        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Wait for the file to be accessible..." -ForegroundColor Cyan

        $fileLocked = $true

        while ($fileLocked) {
            try {
                # Try to open the File (exclusive access)
                $fileStream = [System.IO.File]::Open($filePath, 'Open', 'Read', 'ReadWrite')
                $fileStream.Close()
                
                # If the opening is successful, the file is considered accessible
                $fileLocked = $false
            } catch {
                # If an error occurs, it is assumed that the file is still locked
                Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> File still in use, waiting..." -ForegroundColor Yellow
            }

            # Wait a while before trying the next attempt
            Start-Sleep -Seconds $waitTimeInSeconds
        }

        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> File ist accessible." -ForegroundColor Green
    }

    # Wait until the file has finished writing
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> New File discovered: '$filePath'" -ForegroundColor Green
    Wait-ForFileCompletion $filePath
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Start Transcoding..." -ForegroundColor Green

    # HandBrakeCLI Start command and passthrough output
    $process = Start-Process -FilePath $handBrakeCLI -ArgumentList "-i `"$filePath`" -o `"$outputFile`" --preset-import-file `"$handbrakePresetFile`" -Z `"$handbrakePresetName`"" -NoNewWindow -Wait -PassThru

    # Wait until HandbrakeCLI-Process is finished
    Wait-Process -Id $process.Id

    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Transcoding complete: '$outputFile'" -ForegroundColor Green

    # Delete Source File
    Remove-Item $filePath -Force
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Source File deleted: '$filePath'" -ForegroundColor Yellow
    Write-Host "---------------------------------" -ForegroundColor Magenta
}

# Create monitoring object
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchFolder
$watcher.Filter = "*.mkv"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'
$watcher.EnableRaisingEvents = $true

# Event handler for creating a file (run only once)
Register-ObjectEvent $watcher "Created" -Action $action

# The loop keeps the script running
while ($true) {
    Start-Sleep -Seconds 5
}

# Stop logging
Stop-Transcript