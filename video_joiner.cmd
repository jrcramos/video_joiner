@echo off
setlocal enabledelayedexpansion

:: Get the directory where this script is located
set "scriptDir=%~dp0"

:: ========================================================================
:: CONFIGURATION SECTION - Customize these settings to your preference
:: ========================================================================

:: Path to ffmpeg.exe (will auto-detect if not found at specified location)
:: You can change this to your ffmpeg installation path if needed
set "ffmpeg=C:\ffmpeg\bin\ffmpeg.exe"

:: Temporary directory for processing (will use system temp if this doesn't exist)
:: You can change this to any directory where you have write permissions
set "tempDir=C:\ffmpeg\temp"

:: Video encoding settings - adjust these based on your needs
set "VIDEO_BITRATE=4M"       :: Higher = better quality, larger file (e.g., 2M, 4M, 8M)
set "VIDEO_RESOLUTION=1280x720"  :: Output resolution (e.g., 1920x1080, 1280x720, 854x480)
set "FRAME_RATE=30"          :: Frames per second (e.g., 24, 30, 60)
set "AUDIO_BITRATE=192k"     :: Audio quality (e.g., 128k, 192k, 256k)

:: ========================================================================
:: END CONFIGURATION SECTION
:: ========================================================================

set "processedTempDir=%tempDir%\processed_inputs"

:: Auto-detect ffmpeg if not found at the configured location
if not exist "%ffmpeg%" (
    echo INFO: ffmpeg not found at "%ffmpeg%"
    echo Attempting to auto-detect ffmpeg...
    
    :: Check if ffmpeg is in PATH
    where ffmpeg >nul 2>&1
    if !errorlevel! equ 0 (
        set "ffmpeg=ffmpeg"
        echo SUCCESS: Found ffmpeg in system PATH
    ) else (
        :: Check common installation locations
        if exist "C:\Program Files\ffmpeg\bin\ffmpeg.exe" (
            set "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg.exe"
            echo SUCCESS: Found ffmpeg at C:\Program Files\ffmpeg\bin\ffmpeg.exe
        ) else if exist "%USERPROFILE%\ffmpeg\bin\ffmpeg.exe" (
            set "ffmpeg=%USERPROFILE%\ffmpeg\bin\ffmpeg.exe"
            echo SUCCESS: Found ffmpeg at %USERPROFILE%\ffmpeg\bin\ffmpeg.exe
        ) else (
            echo ERROR: ffmpeg not found!
            echo.
            echo Please install ffmpeg and either:
            echo   1. Add it to your system PATH, or
            echo   2. Update the ffmpeg path in this script's CONFIGURATION SECTION
            echo.
            echo Download ffmpeg from: https://ffmpeg.org/download.html
            pause
            exit /b
        )
    )
)

:: Use system temp directory as fallback if configured temp doesn't exist
if not exist "%tempDir%" (
    set "tempDir=%TEMP%\video_joiner_temp"
    set "processedTempDir=!tempDir!\processed_inputs"
    echo INFO: Using system temp directory: !tempDir!
)

:: Create the temporary directories if they don't exist
if not exist "%tempDir%" mkdir "%tempDir%" >nul 2>&1
if not exist "%processedTempDir%" mkdir "%processedTempDir%" >nul 2>&1
if errorlevel 1 (
    echo FATAL ERROR: Could not create necessary directories.
    echo Please check your permissions for "%tempDir%".
    pause
    exit /b
)

:input_loop
cls
echo ================================
echo    FFmpeg Video Joiner v2.1
echo (Standardizes & Joins for Max Compatibility)
echo ================================
echo.

set /p outputName="Enter output file name (without extension): "
if "%outputName%"=="" goto input_loop

:: Define file paths
set "outputFile=%scriptDir%%outputName%.mp4"
set "listfile=%tempDir%\ffmpeg_raw_file_list.txt"
set "processedListfile=%tempDir%\ffmpeg_processed_file_list.txt"

:: Clean up previous temporary list files and processed videos
if exist "%listfile%" del "%listfile%" >nul
if exist "%processedListfile%" del "%processedListfile%" >nul
del /q "%processedTempDir%\*.mp4" >nul 2>&1

echo.
echo Enter video file paths (one per line).
echo Press ENTER on an empty line when done.
echo TIP: You can drag and drop a file into this window to paste its path.
echo.

:: Manual file entry loop for original files
set "fileCount=0"
:file_entry_loop
set "filePath="
set /p "filePath=File path (or ENTER to finish): "
if "!filePath!"=="" (
    if !fileCount! equ 0 (
        echo No files entered. Please enter at least one file.
        goto file_entry_loop
    ) else (
        goto pre_process_files
    )
)

:: Remove quotes if user pastes them
set "filePath=!filePath:"=!"

if not exist "!filePath!" (
    echo File not found: "!filePath!"
    echo Please check the path and try again.
    goto file_entry_loop
)

:: Add the RAW file path to the list for pre-processing.
echo !filePath!>> "%listfile%"
set /a fileCount+=1
echo Added: !filePath!
goto file_entry_loop

:pre_process_files
set "processedFileCount=0"
for /f "usebackq delims=" %%F in ("%listfile%") do (
    set /a processedFileCount+=1
    set "inputFile=%%F"
    
    for %%N in ("!inputFile!") do set "fileName=%%~nN"
    set "processedFile=%processedTempDir%\!processedFileCount!_!fileName!_processed.mp4"

    (
        echo.
        echo ----------------------------------------------------------------------
        echo Processing file !processedFileCount! of %fileCount%: "!fileName!%%~xN"
        echo This step standardizes each video. Please wait...
        echo ----------------------------------------------------------------------
        echo.
    )

    "%ffmpeg%" -i "!inputFile!" -c:v h264_nvenc -preset p5 -b:v %VIDEO_BITRATE% -s %VIDEO_RESOLUTION% -c:a aac -b:a %AUDIO_BITRATE% -r %FRAME_RATE% -fps_mode cfr -pix_fmt yuv420p "!processedFile!" >nul 2>&1

    if errorlevel 1 (
        echo.
        echo ERROR: Pre-processing failed for "!inputFile!".
        pause
        goto input_loop
    )
    
    :: Add the PROCESSED file to the processed list with the correct concat syntax.
    echo file '!processedFile!'>> "%processedListfile%"
)

:process_files
echo.
echo Concatenating all standardized videos...
echo This should be very fast.
echo.

"%ffmpeg%" -f concat -safe 0 -i "%processedListfile%" -c copy "%outputFile%" >nul 2>&1

if errorlevel 1 (
    echo ERROR: Final video joining failed.
    pause
    goto input_loop
)

:: Clean up temporary files
del /q "%listfile%" >nul 2>&1
del /q "%processedListfile%" >nul 2>&1
rmdir /s /q "%processedTempDir%" >nul 2>&1

(
    echo.
    echo SUCCESS! Merge complete.
    echo Output saved to: "%outputFile%"
)
pause
goto input_loop