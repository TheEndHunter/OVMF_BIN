@echo off
setlocal enabledelayedexpansion

:: Define the date format in the folder names
set folderNameDateFormat=yyyy-MM-dd

:: Get yesterday's date
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set /A year=%datetime:~0,4%, month=%datetime:~4,2%, day=%datetime:~6,2%
set /A yesterday=day-1

:: Format yesterday's date
set yesterdayStr=%year%-%month%-%yesterday%

:: Check if yesterday's folder exists
if not exist ".\%yesterdayStr%" (
    
    :: Move Latest folder to yesterday's date if it exists
    if exist ".\Latest" (
        move ".\Latest" ".\%yesterdayStr%"
    )

    :: Create directory structure
    mkdir .\Latest\
    mkdir .\Latest\ARM
    mkdir .\Latest\ARM\Debug
    mkdir .\Latest\ARM\Release
    mkdir .\Latest\ARM64
    mkdir .\Latest\ARM64\Debug
    mkdir .\Latest\ARM64\Release
    mkdir .\Latest\x86
    mkdir .\Latest\x86\Debug
    mkdir .\Latest\x86\Release
    mkdir .\Latest\x64
    mkdir .\Latest\x64\Debug
    mkdir .\Latest\x64\Release

    :: Download files using PowerShell (Batch doesn't support direct HTTP downloads)
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGAARCH64_QEMU_EFI.fd' -Outfile '.\Latest\ARM64\Debug\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGAARCH64_QEMU_VARS.fd' -Outfile '.\Latest\ARM64\Debug\OVMF_VARS.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEAARCH64_QEMU_EFI.fd' -Outfile '.\Latest\ARM64\Release\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEAARCH64_QEMU_VARS.fd' -Outfile '.\Latest\ARM64\Release\OVMF_VARS.fd'"

    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGARM_QEMU_EFI.fd' -Outfile '.\Latest\ARM\Debug\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGARM_QEMU_VARS.fd' -Outfile '.\Latest\ARM\Debug\OVMF_VARS.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEARM_QEMU_EFI.fd' -Outfile '.\Latest\ARM\Release\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEARM_QEMU_VARS.fd' -Outfile '.\Latest\ARM\Release\OVMF_VARS.fd'"

    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGIa32_OVMF_CODE.fd' -Outfile '.\Latest\x86\Debug\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGIa32_OVMF_VARS.fd' -Outfile '.\Latest\x86\Debug\OVMF_VARS.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEIa32_OVMF_CODE.fd' -Outfile '.\Latest\x86\Release\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEIa32_OVMF_VARS.fd' -Outfile '.\Latest\x86\Release\OVMF_VARS.fd'"

    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGX64_OVMF_CODE.fd' -Outfile '.\Latest\x64\Debug\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGX64_OVMF_VARS.fd' -Outfile '.\Latest\x64\Debug\OVMF_VARS.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEX64_OVMF_CODE.fd' -Outfile '.\Latest\x64\Release\OVMF_CODE.fd'"
    powershell -Command "Invoke-WebRequest 'https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEX64_OVMF_VARS.fd' -Outfile '.\Latest\x64\Release\OVMF_VARS.fd'"
)

:: Delete folders older than 14 days
for /f "delims=" %%i in ('powershell -Command "Get-ChildItem -Path . -Directory | Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}$' } | Sort-Object { [DateTime]::ParseExact($_.Name, 'yyyy-MM-dd', $null) } -Descending | Select-Object -Skip 14 | ForEach-Object { $_.FullName }"') do (
    echo Deleting folder: %%i
    rmdir /s /q "%%i"
)

:: Git commands
git add *
git commit -a -m "Updated OVMF to %date%, removed Oldest Folders"
git push