$sourceDir = "D:\Ripping\04_Handbrake-done\*.mkv"
$destinationDir = "D:\Ripping\05_Filebot-done-transfer"
$filebotFormat = "{~plex}"

# Define Logfile
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "D:\Ripping\98_WinRipEncode-Logs\FileBot\FileBot_$timestamp.log"
Start-Transcript -Path $logFile -Append

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "--------------WinRipEncode--------------" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# Log current date and time
Write-Host (Get-Date) -ForegroundColor Magenta

filebot.exe -rename $sourceDir -non-strict --db TheMovieDB --lang German --apply nfo --action move --conflict skip --output $destinationDir --format $filebotFormat

# Stop logging
Stop-Transcript