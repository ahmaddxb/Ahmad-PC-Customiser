# Define all possible backup/restore tasks in a shared variable.
$allBackupTasks = @{
    "MobaXterm"        = @{ Path = "$env:APPDATA\MobaXterm"; Exclude = @("home", "slash") }
    "Syncthing"        = @{ Path = "$env:LOCALAPPDATA\Syncthing"; Pre = { Stop-Process -Name SyncTrayzor, Syncthing -Force -ErrorAction SilentlyContinue }; Post = { if(Test-Path "$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe"){Start-Process -FilePath "$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe" -WindowStyle Minimized} } }
    "FileZilla"        = @{ Path = "$env:APPDATA\FileZilla" }
    "Fences"           = @{ Path = "$env:APPDATA\Stardock\Fences\Backups" }
    "Windows Sidebar"  = @{ Path = "$env:LOCALAPPDATA\Microsoft\Windows Sidebar" }
    "Windows Terminal" = @{ Path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" }
    "mkcerts"          = @{ Path = "$env:LOCALAPPDATA\mkcert" }
    "JDownloader"      = @{ Path = "$env:ProgramFiles\JDownloader\cfg" }
    "Input Director"   = @{ Export = { & "C:\Program Files\Input Director\IDConfig.exe" -exportconfig:"$($destinationPath)\LatestConfig.xml" }; Import = { & "C:\Program Files\Input Director\IDConfig.exe" -importconfig:"$($sourcePath)\LatestConfig.xml" }; Path = "C:\Program Files\Input Director\IDConfig.exe" }
    "SSH Keys"         = @{ Path = "$env:USERPROFILE\.ssh" }
    "Game Saves"       = @{ Path = "$env:USERPROFILE\Saved Games" }
    "Public Documents" = @{ Path = "$env:PUBLIC\Documents" } # <-- ADDED THIS LINE
}

# --- Backup Function ---
function Start-AppBackup {
    param(
        [string]$baseDestination,
        [string[]]$selectedTasks,
        [System.Windows.Forms.Label]$statusLabel,
        [System.Windows.Forms.ProgressBar]$progressBar,
        [System.Windows.Forms.Form]$form
    )

    $fullComputerName = [System.Net.Dns]::GetHostName()
    $backupRoot = Join-Path -Path $baseDestination -ChildPath "backups\$fullComputerName"
    $skippedItems = @()
    
    $tasksToRun = $selectedTasks | ForEach-Object { @{ Name = $_; Data = $allBackupTasks[$_] } }

    $progressBar.Maximum = $tasksToRun.Count
    $progressBar.Value = 0

    function New-BackupFolder ($destinationPath) {
        if (-not (Test-Path -Path $destinationPath)) { New-Item -ItemType Directory -Path $destinationPath | Out-Null }
    }
    
    foreach ($taskInfo in $tasksToRun) {
        $taskName = $taskInfo.Name
        $task = $taskInfo.Data

        $statusLabel.Text = "Backing up $taskName..."
        $form.Update()

        if ($task.Pre) { & $task.Pre }

        if ($task.Export) {
            if (Test-Path -Path $task.Path) {
                $destinationPath = Join-Path -Path $backupRoot -ChildPath $taskName
                New-BackupFolder $destinationPath
                & $task.Export
            } else { $skippedItems += $taskName }
        } else {
            if (Test-Path -Path $task.Path) {
                $destinationPath = Join-Path -Path $backupRoot -ChildPath ($task.Path -replace ':', '')
                New-BackupFolder $destinationPath
                robocopy $task.Path $destinationPath /E /R:2 /W:5 /NFL /NDL /NJH /NJS /nc /ns /np
            } else { $skippedItems += $taskName }
        }

        if ($task.Post) { & $task.Post }
        $progressBar.PerformStep()
    }

    if ($skippedItems.Count -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("Backup complete, but these items were skipped:`n$($skippedItems -join "`n")", "Backup Complete with warnings")
        $statusLabel.Text = "Backup complete with warnings."
    } else {
        [System.Windows.Forms.MessageBox]::Show("All items were backed up successfully.", "Backup Complete")
        $statusLabel.Text = "Backup complete!"
    }
}

# --- Restore Function ---
function Start-AppRestore {
    param(
        [string]$baseBackupPath,
        [string[]]$selectedTasks,
        [System.Windows.Forms.Label]$statusLabel,
        [System.Windows.Forms.ProgressBar]$progressBar,
        [System.Windows.Forms.Form]$form
    )

    $backupSourceRoot = Get-ChildItem -Path (Join-Path -Path $baseBackupPath -ChildPath "backups") -Directory | Select-Object -First 1
    if (-not $backupSourceRoot) {
        [System.Windows.Forms.MessageBox]::Show("Could not find a computer backup folder inside '$baseBackupPath\backups'.", "Error", "OK", "Error")
        return
    }

    $skippedItems = @()
    $tasksToRun = $selectedTasks | ForEach-Object { @{ Name = $_; Data = $allBackupTasks[$_] } }

    $progressBar.Maximum = $tasksToRun.Count
    $progressBar.Value = 0
    
    foreach ($taskInfo in $tasksToRun) {
        $taskName = $taskInfo.Name
        $task = $taskInfo.Data

        $statusLabel.Text = "Restoring $taskName..."
        $form.Update()

        if ($task.Pre) { & $task.Pre }

        if ($task.Import) {
            $sourcePath = Join-Path -Path $backupSourceRoot.FullName -ChildPath $taskName
            if (Test-Path -Path "$sourcePath\LatestConfig.xml") { & $task.Import }
            else { $skippedItems += $taskName }
        } else {
            $sourcePath = Join-Path -Path $backupSourceRoot.FullName -ChildPath ($task.Path -replace ':', '')
            $destinationPath = $task.Path
            if (Test-Path -Path $sourcePath) {
                robocopy $sourcePath $destinationPath /E /R:2 /W:5 /NFL /NDL /NJH /NJS /nc /ns /np
            } else { $skippedItems += $taskName }
        }

        if ($task.Post) { & $task.Post }
        $progressBar.PerformStep()
    }

    if ($skippedItems.Count -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("Restore complete, but these items were skipped:`n$($skippedItems -join "`n")", "Restore Complete with warnings")
        $statusLabel.Text = "Restore complete with warnings."
    } else {
        [System.Windows.Forms.MessageBox]::Show("All selected items were restored successfully.", "Restore Complete")
        $statusLabel.Text = "Restore complete!"
    }
}
