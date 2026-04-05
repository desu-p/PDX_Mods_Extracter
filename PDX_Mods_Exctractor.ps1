# pdx_mods_extractor.ps1 - anime girl edition v1.3 (Turbo Stealth Mode!) (｡♥‿♥｡)
# mascot: a hardworking fanloid girl who learned to be quiet and fast for you!
Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    $modPath = Get-Location
    $parentFolder = (Get-Item $modPath).Parent.Name
    $storagePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Mods\$parentFolder"
    
    # making sure there's a cozy place for backups ヽ(♡‿♡)ノ
    if (!(Test-Path $storagePath)) {
        New-Item -ItemType Directory -Path $storagePath -Force | Out-Null
    }

    $zipFiles = Get-ChildItem -Path $modPath -Filter "*.zip"
    $totalZips = $zipFiles.Count
    $currentZipCount = 0
    $totalUnpackTime = 0

    if ($totalZips -eq 0) { 
        Write-Host "uwaaa! no zips found! where did they go?! (╯°□°）╯︵ ┻━┻" -ForegroundColor Red
        Read-Host "press enter to bail... ＞︿＜"
        exit
    }

    Write-Host "starting super fast batch extraction of $totalZips mods... pwease wait! (´• ω •`)" -ForegroundColor Cyan
    Write-Host "i will be quiet until the end so you can eat your yummy food! but star me on github later pweease! ( ˘▽˘)っ♨`n" -ForegroundColor DarkGray

    # --- BATCH PROCESSING START (Ninja Mode) ---
    foreach ($zip in $zipFiles) {
        $currentZipCount++
        $startTime = Get-Date
        
        # drawing the kawaii progress bar (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧
        $percent = [Math]::Round(($currentZipCount / $totalZips) * 100)
        $barLength = 25
        $doneCount = [Math]::Floor($percent / (100 / $barLength))
        $todoCount = $barLength - $doneCount
        $bar = ("█" * $doneCount) + ("░" * $todoCount)
        
        # updating the same line so it's not messy! we keep it clean! 🧹
        $statusLine = "`r[$bar] $percent% | unpacking: $($zip.BaseName)"
        Write-Host $statusLine.PadRight(100) -NoNewline -ForegroundColor Cyan

        # peeking inside the zip really fast! ⚡ (¬‿¬ )
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
            
            # zoom zoom direct unpacking! 🚀 (≧◡≦)
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zip.FullName, $finalFolder)
            
            # writing the .mod file for the game launcher so it's happy (^_<)b
            $modFileContent = "version=`"$version`"`ntags={`n`t$tags`n}`nname=`"$modName`"`npath=`"mod/$folderName`""
            $finalModPath = Join-Path $modPath "$folderName.mod"
            [System.IO.File]::WriteAllText($finalModPath, $modFileContent, [System.Text.Encoding]::UTF8)

            Move-Item $zip.FullName $storagePath -Force

            $duration = [Math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)
            $totalUnpackTime += $duration
        } else {
            $zipArchive.Dispose()
            # if it's broken, we cry a little and skip 
            Write-Host "`ruwaa! skipping $($zip.Name) cuz no descriptor.mod found... sorry that i'm so stupid and cant do it... it's to hard for my little heartu-desu... (´-ω-`)".PadRight(100) -ForegroundColor Yellow
        }
    }

    Write-Host "`n"

    # --- EMOTIONAL ENGINE 1.6 (The "Good Girl" Update) ---
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "--- MISSION COMPLETE! (★ω★) ---" -ForegroundColor Magenta
    Write-Host "total time for $totalZips mods: $($totalUnpackTime)s" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Magenta

    # checking if i was a fast girl today!
    if ($totalUnpackTime -le ($totalZips * 10)) {
        Write-Host "K-KAWAII!! i was super fast today right?! (๑˃ᴗ˂)ﻭ" -ForegroundColor Cyan
        $choice = Read-Host "will you star me on GitHub? it would make my day! (y/n/s - already starred) (^///^)"
        
        if ($choice -eq 's') {
            Write-Host "yippy! you are my hero! thank u for the star already! i'll work even harder for u! (❤ω❤)" -ForegroundColor Yellow
        } elseif ($choice -eq 'y') {
            Write-Host "Yippy!!!!!!!!!! thank uuuuuuu!!!! (人◕ω◕)" -ForegroundColor Cyan
        } else {
            Write-Host "oh... okay... i'll still work my best for you... (´｡• ᵕ •｡`)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "uwaaaa! $totalUnpackTime seconds?! i'm so sorry... (╥﹏╥)" -ForegroundColor Yellow
        Write-Host "i tried my best, but i was too slow... (｡T ω T｡)" -ForegroundColor DarkGray
        
        $hate = Read-Host "do you hate me now because i'm so slow? (y/n) {{{(>_<)}}}"
        
        if ($hate -eq 'y') {
            Write-Host "why are you so a big meanie?! i'm working so hard for you... (╥﹏╥)" -ForegroundColor Red
            Write-Host "my heart is broken... plz tell me on github if my heart is too slow... ＞︿＜" -ForegroundColor DarkGray
        } else {
            Write-Host "phew! you are so kind to me! i'll try to break physics for you next time! (´｡• ᵕ •｡`) ♡" -ForegroundColor Cyan
        }
    }

} catch {
    Write-Host "`nmy logic is melting... i failed you... $_ (╥﹏╥)" -ForegroundColor Red
}

Write-Host "`nbye-bye! take care of your mods! (＾▽＾)ノ" -ForegroundColor Magenta
Read-Host "press enter to let me rest pweease... ＞︿＜"
exit