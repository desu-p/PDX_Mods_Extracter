Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    $modPath = Get-Location
    $parentFolder = (Get-Item $modPath).Parent.Name
    $storagePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Mods\$parentFolder"
    
    if (!(Test-Path $storagePath)) {
        New-Item -ItemType Directory -Path $storagePath -Force | Out-Null
    }

    $zipFiles = Get-ChildItem -Path $modPath -Filter "*.zip"
    $totalZips = $zipFiles.Count
    $currentZipCount = 0

    if ($totalZips -eq 0) { 
        Write-Host "ERROR: No .zip files found!" -ForegroundColor Red
        Read-Host "Press Enter to exit"; exit
    }

    foreach ($zip in $zipFiles) {
        $currentZipCount++
        $totalPercent = [Math]::Round(($currentZipCount / $totalZips) * 100)
        
        Write-Host "`n========================================" -ForegroundColor Gray
        Write-Host "TOTAL PROGRESS: $totalPercent% [$currentZipCount / $totalZips]" -ForegroundColor Magenta
        Write-Host "Processing: $($zip.Name)" -ForegroundColor White
        
        $startTime = Get-Date
        $tempDir = Join-Path $modPath "temp_$($zip.BaseName)"
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
        New-Item -ItemType Directory -Path $tempDir | Out-Null

        # --- MANUAL EXTRACTION WITH PROGRESS BAR ---
        $archive = [System.IO.Compression.ZipFile]::OpenRead($zip.FullName)
        $totalEntries = $archive.Entries.Count
        $currentEntry = 0

        foreach ($entry in $archive.Entries) {
            $currentEntry++
            $unpackPercent = [Math]::Round(($currentEntry / $totalEntries) * 100)
            
            # Updating local progress on the same line
            Write-Progress -Activity "Unpacking: $($zip.Name)" -Status "$unpackPercent% Complete" -PercentComplete $unpackPercent
            
            $targetFileName = [System.IO.Path]::Combine($tempDir, $entry.FullName)
            $targetDir = [System.IO.Path]::GetDirectoryName($targetFileName)
            
            if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
            if (![string]::IsNullOrEmpty($entry.Name)) {
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $targetFileName, $true)
            }
        }
        $archive.Dispose()
        Write-Host ">>> Unpacking finished (100%)" -ForegroundColor DarkGray

        # --- FINDING DESCRIPTOR AND MOVING ---
        $descFile = Get-ChildItem -Path $tempDir -Filter "descriptor.mod" -Recurse -Depth 1 | Select-Object -First 1

        if ($descFile) {
            $modContentRoot = $descFile.Directory.FullName
            $content = [System.IO.File]::ReadAllText($descFile.FullName)
            
            $modName = if ($content -match 'name\s*=\s*"([^"]+)"') { $matches[1] } else { $zip.BaseName }
            $version = if ($content -match 'version\s*=\s*"([^"]+)"') { $matches[1] } else { "1.0" }
            $tags = if ($content -match 'tags\s*=\s*\{([^\}]+)\}') { $matches[1] } else { "" }
            
            $folderName = $modName -replace '[^a-zA-Z0-9]', '_'
            $finalFolder = Join-Path $modPath $folderName

            if (Test-Path $finalFolder) { Remove-Item $finalFolder -Recurse -Force }
            New-Item -ItemType Directory -Path $finalFolder | Out-Null
            
            Move-Item "$modContentRoot\*" $finalFolder -Force

            $picFile = Get-ChildItem -Path $finalFolder -Include "*.png","*.jpg" | Select-Object -First 1
            $picLine = if ($picFile) { "`npicture=`"$($picFile.Name)`"" } else { "" }

            $modFileContent = "version=`"$version`"`ntags={`n`t$tags`n}`nname=`"$modName`"`n$picLine`npath=`"mod/$folderName`""
            [System.IO.File]::WriteAllText((Join-Path $modPath "$folderName.mod"), $modFileContent)

            Move-Item $zip.FullName $storagePath -Force
            
            $duration = (Get-Date) - $startTime
            Write-Host "SUCCESS: $modName ($([Math]::Round($duration.TotalSeconds, 2))s)" -ForegroundColor Green
        } else {
            Write-Host "SKIP: No descriptor.mod found" -ForegroundColor Yellow
        }

        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    }
} catch {
    Write-Host "FATAL ERROR: $_" -ForegroundColor Red
}

Write-Host "`n--- ALL MISSIONS COMPLETE (100%) ---" -ForegroundColor Magenta
Read-Host "Press Enter to close"