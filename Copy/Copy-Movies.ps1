$sourceDir = "D:\Ripping\05_Filebot-done-transfer\*"
$destinationDir = "Z:\Filme\Filme"

# Define Logfile
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "D:\Ripping\98_WinRipEncode-Logs\Copy-Item\Movies\Copy-Movies_$timestamp.log"
Start-Transcript -Path $logFile -Append

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "--------------WinRipEncode--------------" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# Log current date and time
Write-Host (Get-Date) -ForegroundColor Magenta

# Output from SourceDir
Get-ChildItem $sourceDir -Recurse -Force

$question1 = Read-Host -Prompt "The Elements listet above will get copyed to '$destinationDir'.`nContinue? (y = yes, continue; n = no, abort)"

switch ($question1.ToLower()) {
    "y" {
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Starting Copy" -ForegroundColor Cyan
        Copy-Item -Path $sourceDir -Destination $destinationDir -Recurse
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Done Copying" -ForegroundColor Green

        $question2 = Read-Host "Remove the Source-Files from: '$sourceDir'?`n(y = yes, Remove Files; n = no, Dont Remove the Files)"

        switch ($question2.ToLower()) {
            "y" {
                Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Deleting Source Files..." -ForegroundColor DarkYellow
                Remove-Item "$sourceDir\*.mkv"
            }
            "n" {
                Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Done." -ForegroundColor Green
            }
            Default {
                Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> No Valid Input..." -ForegroundColor DarkRed
            }
        }

    }
    "n" {
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Abort" -ForegroundColor DarkRed
    }
    Default {
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> No Valid Input..." -ForegroundColor DarkRed
    }
}

# Stop logging
Stop-Transcript