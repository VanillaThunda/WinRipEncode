# Inspiration from: https://gist.github.com/tacofumi/3041eac2f59da7a775c6

# Directory to MakeMKV
$makemkvDir = "C:\Program Files (x86)\MakeMKV"

# Output dir for the raw MKV-Files which are in the making
$workingDir = "D:\Ripping\01_MakeMKV-working"

# Output dir for the finished MKV-Files
$doneDir = "D:\Ripping\02_MakeMKV-done"

# Dir for the Ripped Extras on from the Disc - for further Review in seperate Dir
$extrasDir = "D:\Ripping\03_MakeMKV-extras"

# Directory for the temporary info/title file which is used to get the movie title
$rawTitleFile = "D:\Ripping\98_WinRipEncode-Logs\MakeMKV\title-raw.txt"

# Search Mask to extract the title. The String before and after the title. For me this was my BD-Drive Name/SN and the Drive Letter
$searchBeforeTitle = "BD-RE HL-DT-ST BD-RE BU40N 1\.03 7MEQVHAKKGZ012"
$searchAfterTitle = "E:"

# '--minlength' Defines the minimum lenght for a video file to be ripped - (Default from MakeMKV is 120 Sec.)
$minlength = "240"

# ----------------------------------------------------

# Define Logfile
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFile = "D:\Ripping\98_WinRipEncode-Logs\MakeMKV\MakeMKV_$timestamp.log"
Start-Transcript -Path $logFile -Append

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "--------------WinRipEncode--------------" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# Log current date and time
Write-Host (Get-Date) -ForegroundColor Magenta

Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Searching Disc..." -ForegroundColor Green
# Start MakeMKV Info to get the Basic Disc informations from which we can grab the title of the movie
& "$makemkvDir\makemkvcon.exe" -r info | Out-File -FilePath "$rawTitleFile"

# Check if title-file exists
if (Test-Path $rawTitleFile) {
    # Reading the File
    $titleContent = Get-Content $rawTitleFile -Raw

    # Raw output of the file
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Content of the Title-File: `n$titleContent" -ForegroundColor Cyan

    # Building a Regex to extract the title
    $regex = '"' + $searchBeforeTitle + '","([^"]+)","' + $searchAfterTitle + '"'
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Regex = $regex" -ForegroundColor Green

    # Using the Regex to extract the title
    if ($titleContent -match $regex) {
        # Save the found title in $foundtitle
        $foundtitle = $Matches[1]
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Found Title: '$foundtitle'" -ForegroundColor Green
        $rawTitleFile | Remove-Item
    } else {
        # If no match was found, output an error message
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> No valid Title found!" -ForegroundColor Red
        $rawTitleFile | Remove-Item
        exit
    }
} else {
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> The File '$rawTitleFile' was not found!" -ForegroundColor Red
}

Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Start Ripping..." -ForegroundColor Green

# Execute makemkvcon for ripping (same logic as in Bash)
& "$makemkvDir\makemkvcon.exe" --minlength=$minlength -r --decrypt --directio=true mkv disc:0 all "$workingDir"

# Get all MKV files in the output directory
$mkvFiles = Get-ChildItem "$workingDir\*.mkv"
Get-ChildItem "$workingDir\*.mkv"

if ($mkvFiles.Count -gt 0) {
    # Find the largest MKV file and store only the name
    $largestFileName = ($mkvFiles | Sort-Object Length -Descending | Select-Object -First 1).Name
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Largest File: '$largestFileName'`n" -ForegroundColor Green

    # Move the largest MKV file and rename it with $foundtitle
    Move-Item -Path "$workingDir\$largestFileName" -Destination "$doneDir\$foundtitle.mkv"
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> '$workingDir\$largestFileName' moved to '$doneDir\$foundtitle.mkv'`n" -ForegroundColor Green

    # Rename the moved mkv file
    # Rename-Item -Path "$doneDir\$largestFileName" -NewName "$foundtitle.mkv"
    # Write-Host ">>> '$largestFileName' renamed in '$foundtitle.mkv'`n" -ForegroundColor Green

    # Delete the remaining MKV files (if any), ensuring the largest one is not deleted
    $mkvFiles | Where-Object { $_.Name -ne $largestFileName } | ForEach-Object {
        # Remove-Item (Join-Path $workingDir $_.Name)
        # Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Deleted: $($_.Name)" -ForegroundColor Green
        $extraFile = Join-Path $workingDir $_.Name
        Move-Item -Path "$extraFile" -Destination $extrasDir
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Moved Extra-File: $($_.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> No *.mkv Files found in '$workingDir'!" -ForegroundColor Red
    exit
}

# Eject the disk - PowerShell Version, not working for me:
# (New-Object -ComObject Shell.Application).Namespace(17).ParseName("$discletter\").InvokeVerb("Eject")

# Eject the disk - Windows Media Player must be installed for this to work
Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>> Ejecting Drive..." -ForegroundColor Cyan
(New-Object -com "WMPlayer.OCX.7").cdromcollection.item(0).eject()

Write-Host "[$(Get-Date -Format "yyyy-MM-dd - HH:mm:ss")] >>>Title: '$foundtitle.mkv' created<<<" -ForegroundColor Green

# Stop logging
Stop-Transcript
