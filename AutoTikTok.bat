@echo off
setlocal enabledelayedexpansion

set "inputFolder=W:\Upload\2024\February\15"
set "sourceFolder=W:\FFMPEG\AUTOTIKTOK\source\"
set "completedFolder=W:\FFMPEG\AUTOTIKTOK\source\completed\"
set "exportFolder=W:\FFMPEG\AUTOTIKTOK\export\"
set "ffmpegPath=.\ffmpeg.exe"
set "backgroundImage=.\001-red-bg.png"
set "fontFile=.\arial.ttf"  :: Replace with the actual path to the TTF font file

:mainLoop
:: Create the source folder if it doesn't exist
if not exist "!sourceFolder!" mkdir "!sourceFolder!"

:: Copy all files from the input folder and subfolders to the source folder
for /r "%inputFolder%" %%i in (*.mp4) do (
    set "sourceFile=!sourceFolder!\%%~nxi"
    copy "%%i" "!sourceFolder!\" > nul
    echo Copied: "%%i"
)

:: Process files in the source folder
for %%i in ("!sourceFolder!\*.mp4") do (
    :: Process the file only if the exported file doesn't exist
    set "exportFile=!exportFolder!\%%~ni_exported.mp4"
    if not exist "!exportFile!" (
        for /f "delims=" %%d in ('powershell Get-Date -Format dd-MM-yyyy') do (
            set "currentDate=%%d"
        )
        set "drawtext=text='!currentDate!':fontfile='arial.ttf':fontcolor=white:fontsize=70:x=(w-text_w)/2:y=h-th-400"
        "%ffmpegPath%" -i "%%i" -i "!backgroundImage!" -filter_complex "[0:v]scale=1260:1260,pad=1280:2260:(ow-iw)/2:(oh-ih)/2[v1];[v1][1:v]overlay=0:0,drawtext=!drawtext!" -c:a copy -c:v libx264 -crf 23 "!exportFile!"
        
        :: Move the source file to the completed folder
        move "%%i" "!completedFolder!"
        echo Processed and moved: "%%i"
    ) else (
        echo Skipped: "%%i" (Already processed)
    )
)

echo All files processed and moved to export and completed folders.

:: Countdown display for one minute
for /l %%s in (60,-1,1) do (
    cls
    echo Countdown: %%s seconds
    timeout /t 1 > nul
)

goto mainLoop

pause





