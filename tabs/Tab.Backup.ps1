$tabBackup = New-Object System.Windows.Forms.TabPage
$tabBackup.Text = "Backup & Restore"
$tabBackup.AutoScroll = $true
$tabBackup.BackColor = $theme.Background
$tabControl.Controls.Add($tabBackup)

# Define the list of items that can be backed up or restored
$backupRestoreItems = @(
    "MobaXterm", "Syncthing", "FileZilla", "Fences",
    "Windows Sidebar", "Windows Terminal", "mkcerts",
    "JDownloader", "Input Director", "SSH Keys", "Game Saves", "Public Documents"
)

#==================================================================
# GroupBox for Backup
#==================================================================
$backupGroupBox = New-Object System.Windows.Forms.GroupBox
$backupGroupBox.Location = [System.Drawing.Point]::new(10, 10)
$backupGroupBox.Size = New-Object System.Drawing.Size(425, 310) #<-- Adjusted height
$backupGroupBox.Text = "Backup"
$backupGroupBox.ForeColor = $theme.Foreground
$backupGroupBox.Font = $theme.Font
$tabBackup.Controls.Add($backupGroupBox)

# --- Create Checkboxes for Backup ---
$backupCheckboxes = @()
$yBackup = 30
$selectAllBackupCheckbox = New-Object System.Windows.Forms.CheckBox
$selectAllBackupCheckbox.Location = [System.Drawing.Point]::new(20, $yBackup); $selectAllBackupCheckbox.Size = New-Object System.Drawing.Size(300, 20); $selectAllBackupCheckbox.Text = "Select All"; $selectAllBackupCheckbox.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold); $selectAllBackupCheckbox.ForeColor = $theme.Foreground; $backupGroupBox.Controls.Add($selectAllBackupCheckbox); $yBackup += 25

$itemIndex = 0
$itemsInFirstColumn = [math]::Ceiling($backupRestoreItems.Count / 2)
foreach ($item in $backupRestoreItems) {
    $xPos = 0; $yPos = 0
    if ($itemIndex -lt $itemsInFirstColumn) {
        $xPos = 40
        $yPos = $yBackup + ($itemIndex * 20)
    } else {
        $xPos = 220
        $yPos = $yBackup + (($itemIndex - $itemsInFirstColumn) * 20)
    }
    $checkbox = New-Object System.Windows.Forms.CheckBox; $checkbox.Location = [System.Drawing.Point]::new($xPos, $yPos); $checkbox.Size = New-Object System.Drawing.Size(180, 20); $checkbox.Text = $item; $checkbox.ForeColor = $theme.Foreground; $checkbox.Font = $theme.Font
    $backupGroupBox.Controls.Add($checkbox); $backupCheckboxes += $checkbox; $itemIndex++
}
$selectAllBackupCheckbox.Add_Click({ foreach ($cb in $backupCheckboxes) { $cb.Checked = $selectAllBackupCheckbox.Checked } })

# --- Backup Destination and Button ---
$yBackup = 180 #<-- CHANGED FROM 160
$backupDestLabel = New-Object System.Windows.Forms.Label; $backupDestLabel.Location = [System.Drawing.Point]::new(10, $yBackup); $backupDestLabel.Size = New-Object System.Drawing.Size(400, 20); $backupDestLabel.Text = "Backup Destination:"; $backupDestLabel.ForeColor = $theme.Foreground; $backupGroupBox.Controls.Add($backupDestLabel); $yBackup += 20
$backupPathTextBox = New-Object System.Windows.Forms.TextBox; $backupPathTextBox.Location = [System.Drawing.Point]::new(10, $yBackup); $backupPathTextBox.Size = New-Object System.Drawing.Size(320, 20); $backupPathTextBox.ReadOnly = $true; $backupPathTextBox.BackColor = $theme.Control; $backupPathTextBox.ForeColor = $theme.Foreground; $backupGroupBox.Controls.Add($backupPathTextBox)
$browseBackupButton = New-Object System.Windows.Forms.Button; $browseBackupButton.Location = [System.Drawing.Point]::new(340, $yBackup - 2); $browseBackupButton.Size = New-Object System.Drawing.Size(75, 25); $browseBackupButton.Text = "Browse..."; $browseBackupButton.BackColor = $theme.Control; $browseBackupButton.ForeColor = $theme.Foreground; $browseBackupButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat; $backupGroupBox.Controls.Add($browseBackupButton); $yBackup += 30
$backupButton = New-Object System.Windows.Forms.Button; $backupButton.Location = [System.Drawing.Point]::new(150, $yBackup); $backupButton.Size = New-Object System.Drawing.Size(120, 30); $backupButton.Text = "Start Backup"; $backupButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold); $backupButton.BackColor = $theme.Accent; $backupButton.ForeColor = $theme.Foreground; $backupButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat; $backupGroupBox.Controls.Add($backupButton)
$backupProgressBar = New-Object System.Windows.Forms.ProgressBar; $backupProgressBar.Location = [System.Drawing.Point]::new(10, $yBackup + 40); $backupProgressBar.Size = New-Object System.Drawing.Size(405, 20); $backupGroupBox.Controls.Add($backupProgressBar)
$backupStatusLabel = New-Object System.Windows.Forms.Label; $backupStatusLabel.Location = [System.Drawing.Point]::new(10, $yBackup + 65); $backupStatusLabel.AutoSize = $true; $backupStatusLabel.Text = "Select items and destination."; $backupStatusLabel.ForeColor = $theme.Foreground; $backupGroupBox.Controls.Add($backupStatusLabel)

#==================================================================
# GroupBox for Restore
#==================================================================
$restoreGroupBox = New-Object System.Windows.Forms.GroupBox
$restoreGroupBox.Location = [System.Drawing.Point]::new(10, 330) #<-- Adjusted Y
$restoreGroupBox.Size = New-Object System.Drawing.Size(425, 310) #<-- Adjusted height
$restoreGroupBox.Text = "Restore"
$restoreGroupBox.ForeColor = $theme.Foreground
$restoreGroupBox.Font = $theme.Font
$tabBackup.Controls.Add($restoreGroupBox)

# --- Create Checkboxes for Restore ---
$restoreCheckboxes = @()
$yRestore = 30
$selectAllRestoreCheckbox = New-Object System.Windows.Forms.CheckBox; $selectAllRestoreCheckbox.Location = [System.Drawing.Point]::new(20, $yRestore); $selectAllRestoreCheckbox.Size = New-Object System.Drawing.Size(300, 20); $selectAllRestoreCheckbox.Text = "Select All"; $selectAllRestoreCheckbox.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold); $selectAllRestoreCheckbox.ForeColor = $theme.Foreground; $restoreGroupBox.Controls.Add($selectAllRestoreCheckbox); $yRestore += 25

$itemIndex = 0
foreach ($item in $backupRestoreItems) {
    $xPos = 0; $yPos = 0
    if ($itemIndex -lt $itemsInFirstColumn) {
        $xPos = 40
        $yPos = $yRestore + ($itemIndex * 20)
    } else {
        $xPos = 220
        $yPos = $yRestore + (($itemIndex - $itemsInFirstColumn) * 20)
    }
    $checkbox = New-Object System.Windows.Forms.CheckBox; $checkbox.Location = [System.Drawing.Point]::new($xPos, $yPos); $checkbox.Size = New-Object System.Drawing.Size(180, 20); $checkbox.Text = $item; $checkbox.ForeColor = $theme.Foreground; $checkbox.Font = $theme.Font
    $restoreGroupBox.Controls.Add($checkbox); $restoreCheckboxes += $checkbox; $itemIndex++
}
$selectAllRestoreCheckbox.Add_Click({ foreach ($cb in $restoreCheckboxes) { $cb.Checked = $selectAllRestoreCheckbox.Checked } })

# --- Restore Source and Button ---
$yRestore = 180 #<-- CHANGED FROM 160
$restoreDestLabel = New-Object System.Windows.Forms.Label; $restoreDestLabel.Location = [System.Drawing.Point]::new(10, $yRestore); $restoreDestLabel.Size = New-Object System.Drawing.Size(400, 20); $restoreDestLabel.Text = "Restore From (select parent folder):"; $restoreDestLabel.ForeColor = $theme.Foreground; $restoreGroupBox.Controls.Add($restoreDestLabel); $yRestore += 20
$restorePathTextBox = New-Object System.Windows.Forms.TextBox; $restorePathTextBox.Location = [System.Drawing.Point]::new(10, $yRestore); $restorePathTextBox.Size = New-Object System.Drawing.Size(320, 20); $restorePathTextBox.ReadOnly = $true; $restorePathTextBox.BackColor = $theme.Control; $restorePathTextBox.ForeColor = $theme.Foreground; $restoreGroupBox.Controls.Add($restorePathTextBox)
$browseRestoreButton = New-Object System.Windows.Forms.Button; $browseRestoreButton.Location = [System.Drawing.Point]::new(340, $yRestore - 2); $browseRestoreButton.Size = New-Object System.Drawing.Size(75, 25); $browseRestoreButton.Text = "Browse..."; $browseRestoreButton.BackColor = $theme.Control; $browseRestoreButton.ForeColor = $theme.Foreground; $browseRestoreButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat; $restoreGroupBox.Controls.Add($browseRestoreButton); $yRestore += 30
$restoreButton = New-Object System.Windows.Forms.Button; $restoreButton.Location = [System.Drawing.Point]::new(150, $yRestore); $restoreButton.Size = New-Object System.Drawing.Size(120, 30); $restoreButton.Text = "Start Restore"; $restoreButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold); $restoreButton.BackColor = $theme.Accent; $restoreButton.ForeColor = $theme.Foreground; $restoreButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat; $restoreGroupBox.Controls.Add($restoreButton)
$restoreProgressBar = New-Object System.Windows.Forms.ProgressBar; $restoreProgressBar.Location = [System.Drawing.Point]::new(10, $yRestore + 40); $restoreProgressBar.Size = New-Object System.Drawing.Size(405, 20); $restoreGroupBox.Controls.Add($restoreProgressBar)
$restoreStatusLabel = New-Object System.Windows.Forms.Label; $restoreStatusLabel.Location = [System.Drawing.Point]::new(10, $yRestore + 65); $restoreStatusLabel.AutoSize = $true; $restoreStatusLabel.Text = "Select items and source."; $restoreStatusLabel.ForeColor = $theme.Foreground; $restoreGroupBox.Controls.Add($restoreStatusLabel)

#==================================================================
# Button Click Logic
#==================================================================
$browseBackupButton.Add_Click({ try { $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; if ($folderBrowser.ShowDialog() -eq "OK") { $backupPathTextBox.Text = $folderBrowser.SelectedPath } } catch { [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error") } })
$browseRestoreButton.Add_click({ try { $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; if ($folderBrowser.ShowDialog() -eq "OK") { $selectedPath = $folderBrowser.SelectedPath; $restorePathTextBox.Text = $selectedPath; if (-not $allBackupTasks) { $restoreStatusLabel.Text = "Error: Backup config not loaded."; return }; $backupSourceRoot = Get-ChildItem -Path (Join-Path -Path $selectedPath -ChildPath "backups") -Directory -ErrorAction SilentlyContinue | Select-Object -First 1; if ($backupSourceRoot) { foreach ($checkbox in $restoreCheckboxes) { $checkbox.Checked = $false; $appName = $checkbox.Text; $taskData = $allBackupTasks[$appName]; if ($taskData) { $expectedBackupPath = ""; if ($taskData.Export) { $expectedBackupPath = Join-Path -Path $backupSourceRoot.FullName -ChildPath $appName } else { $mangledPathName = ($taskData.Path -replace ':', ''); $expectedBackupPath = Join-Path -Path $backupSourceRoot.FullName -ChildPath $mangledPathName }; if (Test-Path -Path $expectedBackupPath) { $checkbox.Checked = $true } } } } else { foreach ($checkbox in $restoreCheckboxes) { $checkbox.Checked = $false } } } } catch { [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error") } })
$backupButton.Add_Click({ $selectedTasks = $backupCheckboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Text }; if ($selectedTasks.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Please select at least one item to back up.", "Error"); return }; if ([string]::IsNullOrWhiteSpace($backupPathTextBox.Text)) { [System.Windows.Forms.MessageBox]::Show("Please select a backup destination.", "Error"); return }; Start-AppBackup -baseDestination $backupPathTextBox.Text -selectedTasks $selectedTasks -statusLabel $backupStatusLabel -progressBar $backupProgressBar -form $form })
$restoreButton.Add_Click({ $selectedTasks = $restoreCheckboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Text }; if ($selectedTasks.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Please select at least one item to restore.", "Error"); return }; if ([string]::IsNullOrWhiteSpace($restorePathTextBox.Text)) { [System.Windows.Forms.MessageBox]::Show("Please select the source backup folder.", "Error"); return }; Start-AppRestore -baseBackupPath $restorePathTextBox.Text -selectedTasks $selectedTasks -statusLabel $restoreStatusLabel -progressBar $restoreProgressBar -form $form })