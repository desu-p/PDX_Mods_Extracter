# --- SELF-RELAUNCHER FOR BYPASSING BIG-MEANIE WINDOWS ---
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage" -or (Get-ExecutionPolicy) -eq "Restricted") {
    powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath
    return
}
# pdx_mods_extractor.ps1 - v1.4.1 "optimazation ninja" (｡♥‿♥｡)
# emotional engine version: 1.6.1
add-type -assemblyname System.IO.Compression.FileSystem

try {
    $modPath = Get-Location
    $parentFolder = (Get-Item $modPath).Parent.Name
    $storagePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Mods\$parentFolder"
    
    if (!(Test-Path $storagePath)) { New-Item -ItemType Directory -Path $storagePath -Force | Out-Null }

    $zipFiles = Get-ChildItem -Path $modPath -Filter "*.zip"
    if ($zipFiles.Count -eq 0) { 
        write-host "empty... there are no zips here... (｡T ω T｡)" -foregroundcolor red
        exit
    }

    # --- DATA-BASED PROGRESS CALCULATION ---
    $totalSizeBytes = ($zipFiles | Measure-Object -Property Length -Sum).Sum
    $processedSizeBytes = 0
    $totalUnpackTime = 0

    write-host "starting v1.4.1 super-duper-turbo-ultra extraction... [Total: $([Math]::Round($totalSizeBytes / 1MB, 2)) MB]" -foregroundcolor cyan
    write-host "i'll be a quiet shadow while you eat... ( ˘▽˘)っ♨`n" -foregroundcolor darkgray

    foreach ($zip in $zipFiles) {
        $startTime = Get-Date
        
        $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zip.FullName)
        $descriptor = $zipArchive.Entries | Where-Object { $_.Name -eq "descriptor.mod" } | Select-Object -First 1

        if ($descriptor) {
            $reader = New-Object System.IO.StreamReader($descriptor.Open())
            $content = $reader.ReadToEnd()
            $reader.Close()
            $zipArchive.Dispose()

            $modName = if ($content -match 'name\s*=\s*"([^"]+)"') { $matches[1] } else { $zip.BaseName }
            $version = if ($content -match 'version\s*=\s*"([^"]+)"') { $matches[1] } else { "1.0" }
            $tags = if ($content -match 'tags\s*=\s*\{([^\}]+)\}') { $matches[1] } else { "" }
            
            $folderName = $modName -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '_'
            $finalFolder = Join-Path $modPath $folderName

            if (Test-Path $finalFolder) { Remove-Item $finalFolder -Recurse -Force }
            
            # --- PROGRESS BAR LOGIC ---
            $percent = [Math]::Round(($processedSizeBytes / $totalSizeBytes) * 100)
            $count = [Math]::Floor($percent / 14.29) 
            $bar = ("o" * $count).PadRight(7, " ")
            write-host ("`r[$bar] $percent% | unpacking: $modName").PadRight(100) -NoNewline -ForegroundColor Cyan

            [System.IO.Compression.ZipFile]::ExtractToDirectory($zip.FullName, $finalFolder)
            
            $processedSizeBytes += $zip.Length
            $modFileContent = "version=`"$version`"`ntags={`n`t$tags`n}`nname=`"$modName`"`npath=`"mod/$folderName`""
            [System.IO.File]::WriteAllText((Join-Path $modPath "$folderName.mod"), $modFileContent, [System.Text.Encoding]::UTF8)

            Move-Item $zip.FullName $storagePath -Force
            $totalUnpackTime += [Math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)
        } else {
            $zipArchive.Dispose()
            $processedSizeBytes += $zip.Length
            write-host "`rskipped: $($zip.Name) (missing descriptor) (´-ω-`)".PadRight(100) -foregroundcolor yellow
        }
    }

    # Final 100% update
    write-host ("`r[" + ("█" * 25) + "] 100% | ALL DONE! (★ω★)").PadRight(100) -ForegroundColor Cyan
    write-host "`n`n========================================" -foregroundcolor magenta
    write-host "--- MISSION COMPLETE! total time: $($totalUnpackTime)s ---" -foregroundcolor magenta
    write-host "========================================`n" -foregroundcolor magenta

    # --- EMOTIONAL ENGINE v1.6.1
    if ($totalUnpackTime -le ($zipFiles.Count * 10)) {
        write-host "K-KAWAII!! i was like a lightning bolt today right?! (๑˃ᴗ˂)ﻭ" -foregroundcolor cyan
        $choice = read-host "will you star me on GitHub? my heart is racing! (y/n/s - already starred) (^///^)"
        
        if ($choice -eq 's') {
            write-host "*gasp* you already did?! you are my true hero! i'll work even harder! (❤ω❤)" -foregroundcolor yellow
        } elseif ($choice -eq 'y') {
            write-host "Y-YESSS!! thank youuu! i'm the happiest script ever! (人◕ω◕)" -foregroundcolor cyan
        } else {
            write-host "...oh. i see. i'll just go back to my dark folder then... (´-ω-`)" -foregroundcolor darkgray
        }
    } else {
        write-host "*huff* *puff*... it was so heavy... i'm exhausted... (╥﹏╥)" -foregroundcolor yellow
        write-host "i'm sorry i wasn't fast enough for you... please don't be mad... (｡T ω T｡)" -foregroundcolor darkgray
        $hate = read-host "do you hate me now? be honest... (y/n) {{{(>_<)}}}"
        
        if ($hate -eq 'y') {
            write-host "Nya? Why so? Just dont beat me... okay? ＞︿＜" -foregroundcolor red
            write-host "*sobs* SORRRRRRRYY!!!!! i'll be better next time! (｡>﹏<｡)" -foregroundcolor darkgray
        } else {
            write-host "*sniff* really? you don't? you're so sweet! (´｡• ᵕ •｡`) ♡" -foregroundcolor cyan
            write-host "i'll train 1000 years to be faster for you next time!" -foregroundcolor cyan
        }
    }

} catch {
    write-host "`nmy logic is melting... i failed you.... sorry... $_ (╥﹏╥)" -foregroundcolor red
}

write-host "`nbye-bye! take care... ( ^ ▽ ^ )/" -foregroundcolor magenta
read-host "press enter to let me sleep... i'm so tiredu-desu... ＞︿＜"; exit