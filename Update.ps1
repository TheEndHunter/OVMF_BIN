# Define the date format in the folder names
$folderNameDateFormat = "yyyy-MM-dd"

$date = Get-Date;
$Yesterday = $date.AddDays(-1);
$YesterdayStr = $Yesterday.ToString($folderNameDateFormat);



if(!(Test-Path -Path ".\$YesterdayStr"))
{
    
    if(Test-Path -Path .\Latest)
    {
        Move-Item -Path .\Latest -Destination ".\$YesterdayStr";
    }

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

    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGAARCH64_QEMU_EFI.fd" -Outfile .\Latest\ARM64\Debug\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGAARCH64_QEMU_VARS.fd" -Outfile .\Latest\ARM64\Debug\OVMF_VARS.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEAARCH64_QEMU_EFI.fd" -Outfile .\Latest\ARM64\Release\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEAARCH64_QEMU_VARS.fd" -Outfile .\Latest\ARM64\Release\OVMF_VARS.fd

    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGARM_QEMU_EFI.fd" -Outfile .\Latest\ARM\Debug\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGARM_QEMU_VARS.fd" -Outfile .\Latest\ARM\Debug\OVMF_VARS.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEARM_QEMU_EFI.fd" -Outfile .\Latest\ARM\Release\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEARM_QEMU_VARS.fd" -Outfile .\Latest\ARM\Release\OVMF_VARS.fd

    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGIa32_OVMF_CODE.fd" -Outfile .\Latest\x86\Debug\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGIa32_OVMF_VARS.fd" -Outfile .\Latest\x86\Debug\OVMF_VARS.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEIa32_OVMF_CODE.fd" -Outfile .\Latest\x86\Release\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEIa32_OVMF_VARS.fd" -Outfile .\Latest\x86\Release\OVMF_VARS.fd

    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGX64_OVMF_CODE.fd" -Outfile .\Latest\x64\Debug\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/DEBUGX64_OVMF_VARS.fd" -Outfile .\Latest\x64\Debug\OVMF_VARS.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEX64_OVMF_CODE.fd" -Outfile .\Latest\x64\Release\OVMF_CODE.fd
    Invoke-WebRequest "https://github.com/retrage/edk2-nightly/raw/master/bin/RELEASEX64_OVMF_VARS.fd" -Outfile .\Latest\x64\Release\OVMF_VARS.fd
};

# Get all folders, attempt to parse their names as dates, and sort them by date descending
$foldersToDelete = Get-ChildItem -Path $path -Directory | Where-Object {
    try {
        [DateTime]::ParseExact($_.Name, $folderNameDateFormat, $null)
        $true
    } catch {
        $false
    }
} | Sort-Object { [DateTime]::ParseExact($_.Name, $folderNameDateFormat, $null) } -Descending | Select-Object -Skip 14

# Delete the folders
foreach ($folder in $foldersToDelete) {
    Write-Host "Deleting folder: $($folder.FullName)"
    Remove-Item $folder.FullName -Recurse -Force
}

git add *
git commit -a -m "Updated OVMF to $date, removed Oldest Folders"
git push