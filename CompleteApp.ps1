#----------------------------------
#  SCRIPT CONFIGURATION
#----------------------------------
#requires -version 5.1
#requires -runasadministrator

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    break
}

#==================================================================
# CONFIGURATION DATA
#==================================================================

$packageMappings = @{
    "*Microsoft.GetHelp*"                       = "Microsoft Get Help"
    "*Microsoft.ZuneVideo*"                     = "Microsoft Films & TV"
    "*Microsoft.ZuneMusic*"                     = "Windows Media Player"
    "*Microsoft.549981C3F5F10*"                 = "Cortana"
    "*Microsoft.MicrosoftSolitaireCollection*"  = "Microsoft Solitaire Collection"
    "*Microsoft.BingNews*"                      = "Microsoft Bing News"
    "*Microsoft.WindowsFeedbackHub*"            = "Microsoft Windows Feedback Hub"
    "*Microsoft.WindowsMaps*"                   = "Microsoft Windows Maps"
    "*Microsoft.WindowsAlarms*"                 = "Microsoft Windows Alarms"
    "*Microsoft.BingWeather*"                   = "Microsoft Bing Weather"
    "*Clipchamp.Clipchamp*"                     = "Microsoft Clipchamp"
    "*MicrosoftCorporationII.QuickAssist*"      = "Microsoft Quick Assist"
    "*Microsoft.Getstarted*"                    = "Microsoft Get Started"
    "*Microsoft.MicrosoftOfficeHub*"            = "Microsoft Office Hub"
    "*SpotifyAB.SpotifyMusic*"                  = "Spotify"
    "*skypeapp*"                                = "Skype"
    "*Microsoft.MixedReality*"                  = "Microsoft Mixed Reality"
    "*onenote*"                                 = "Microsoft Onenote"
    "*windowscommunicationsapps*"               = "Microsoft Mail and Calendar"
    "*MicrosoftTeams*"                          = "Microsoft Teams"
    "*xbox*"                                    = "All Other Xbox Apps"
    "*Microsoft.GamingApp*"                     = "Xbox App"
}

$windowsTweaksMapping = @{
    "Enable Dark Mode"                                                    = {
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force
    }
    "Open File Explorer to This PC"                                       = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 }
    "File Explorer Show File Extentions"                                  = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 }
    "File Explorer show hidden files"                                     = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 }
    "Hide Widget on Task Bar"                                             = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 }
    "Set desktop icon size to small"                                      = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "IconSize" -Value 32 -Force
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "Mode" -Value 1 -Force
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "LogicalViewMode" -Value 3 -Force
    }
    "windows 11 task bar to hide search"                                  = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force }
    "Hide Chat on Task Bar"                                               = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Force }
    "disable search web results on Windows 11"                            = {
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name DisableSearchBoxSuggestions -Value 1 -PropertyType DWORD -Force
    }
    "Show This PC on desktop"                                             = { New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Force }
    "Turn on Use Print Screen Key to Open Screen Snipping"                = { New-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 1 -Force }
    "Turn On Set Time Zone Automatically"                                 = {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3 -Force
        Set-TimeZone -Name "Arabian Standard Time"
        Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c w32tm /resync"
    }
    "Change Time Format"                                                  = {
        New-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "h:mm tt" -Force
        New-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "h:mm:ss tt" -Force
    }
    "Turn off Automatic Proxy Configuration"                              = {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "AutoDetect" -Value 0
    }
    "Change UAC Behavior for Administrators to Elevate without prompting" = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0" -Force }
    "Turn On Receive Updates for Other Microsoft Products"                = {
        (New-Object -com "Microsoft.Update.ServiceManager").AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "AllowMUUpdateService" -Value "1" -Force
    }
    "Turn On Get me up to date for Windows Update"                        = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsExpedited" -Value "1" -Force }
    "Turn On Auto-restart Notifications for Windows Update in Settings"   = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Value "1" -Force }
    "Get Latest Updates as soon as available in Windows 11"               = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsContinuousInnovationOptedIn" -Value "1" -Force }
}

$appsToInstallMapping = @{
    "Google Chrome"      = "Google.Chrome"
    "Mozilla Firefox"    = "Mozilla.Firefox"
    "7-Zip"              = "7zip.7zip"
    "VLC Media Player"   = "VideoLAN.VLC"
    "Notepad++"          = "Notepad++.Notepad++"
    "Visual Studio Code" = "Microsoft.VisualStudioCode"
    "PowerToys"          = "Microsoft.PowerToys"
    "Everything"         = "voidtools.Everything"
}

#==================================================================
# FUNCTION DEFINITIONS
#==================================================================

function RefreshCheckboxesRemoveApp {
    foreach ($checkboxInfo in $checkboxes) {
        $packageName = $checkboxInfo.Name
        $checkbox = $checkboxInfo.Checkbox
        $package = Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $packageName
        $checkbox.Checked = ($null -ne $package)
    }
}

function IsTweakApplied($tweakName) {
    switch ($tweakName) {
        "Enable Dark Mode" {
            $appsUseLightTheme = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
            $systemUsesLightTheme = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -ErrorAction SilentlyContinue
            return ($appsUseLightTheme -eq 0) -and ($systemUsesLightTheme -eq 0)
        }
        "Open File Explorer to This PC" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "File Explorer Show File Extentions" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "File Explorer show hidden files" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Hide Widget on Task Bar" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "Set desktop icon size to small" {
            $iconSizeValue = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "IconSize" -ErrorAction SilentlyContinue
            return ($iconSizeValue -eq 32)
        }
        "windows 11 task bar to hide search" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "Hide Chat on Task Bar" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "disable search web results on Windows 11" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Show This PC on desktop" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
            return ($null -ne $registryValue -and $registryValue -eq 0)
        }
        "Turn on Use Print Screen Key to Open Screen Snipping" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Turn On Set Time Zone Automatically" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -ErrorAction SilentlyContinue
            return ($registryValue -eq 3)
        }
        "Change Time Format" {
            $sShortTime = Get-ItemPropertyValue -Path "HKCU:\Control Panel\International" -Name "sShortTime" -ErrorAction SilentlyContinue
            $sTimeFormat = Get-ItemPropertyValue -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -ErrorAction SilentlyContinue
            return ($sShortTime -eq "h:mm tt") -and ($sTimeFormat -eq "h:mm:ss tt")
        }
        "Turn off Automatic Proxy Configuration" {
            $ProxyEnable = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -ErrorAction SilentlyContinue
            return ($ProxyEnable -eq 0)
        }
        "Change UAC Behavior for Administrators to Elevate without prompting" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "Turn On Receive Updates for Other Microsoft Products" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "AllowMUUpdateService" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Turn On Get me up to date for Windows Update" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsExpedited" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Turn On Auto-restart Notifications for Windows Update in Settings" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Get Latest Updates as soon as available in Windows 11" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsContinuousInnovationOptedIn" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        default {
            return $false
        }
    }
}

function RefreshCheckboxesTweaks {
    foreach ($checkbox in $checkboxesWindowsTweaks) {
        $tweakName = $checkbox.Text
        $checkbox.Checked = IsTweakApplied($tweakName)
    }
}

function Update-InstalledAppCheckboxes_Synchronous {
    param(
        [System.Windows.Forms.Button]$checkButton,
        [System.Windows.Forms.Button]$installButton,
        [System.Windows.Forms.Label]$statusLabel,
        [System.Windows.Forms.Form]$form
    )
    $checkButton.Enabled = $false
    $installButton.Enabled = $false
    $statusLabel.Text = "Checking... The app will now freeze."
    $form.Update()

    foreach ($checkbox in $checkboxesInstallApps) {
        $appName = $checkbox.Text
        $appId = $appsToInstallMapping[$appName]
        $isInstalled = winget list --id $appId --accept-source-agreements | Select-String -Pattern $appId -SimpleMatch -Quiet
        $checkbox.Checked = $isInstalled
    }

    $statusLabel.Text = "Check complete."
    $checkButton.Enabled = $true
    $installButton.Enabled = $true
}

$allBackupTasks = @{
    "MobaXterm"        = @{ Path = "$env:APPDATA\MobaXterm"; Exclude = @("home", "slash") }
    "Syncthing"        = @{ Path = "$env:LOCALAPPDATA\Syncthing"; Pre = { Stop-Process -Name SyncTrayzor, Syncthing -Force -ErrorAction SilentlyContinue }; Post = { if (Test-Path "$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe") { Start-Process -FilePath "$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe" -WindowStyle Minimized } } }
    "FileZilla"        = @{ Path = "$env:APPDATA\FileZilla" }
    "Fences"           = @{ Path = "$env:APPDATA\Stardock\Fences\Backups" }
    "Windows Sidebar"  = @{ Path = "$env:LOCALAPPDATA\Microsoft\Windows Sidebar" }
    "Windows Terminal" = @{ Path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" }
    "mkcerts"          = @{ Path = "$env:LOCALAPPDATA\mkcert" }
    "JDownloader"      = @{ Path = "$env:ProgramFiles\JDownloader\cfg" }
    "Input Director"   = @{ Export = { & "C:\Program Files\Input Director\IDConfig.exe" -exportconfig:"$($destinationPath)\LatestConfig.xml" }; Import = { & "C:\Program Files\Input Director\IDConfig.exe" -importconfig:"$($sourcePath)\LatestConfig.xml" }; Path = "C:\Program Files\Input Director\IDConfig.exe" }
}

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


#==================================================================
# FORM AND UI CREATION
#==================================================================
Add-Type -AssemblyName System.Windows.Forms

# --- Main Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ahmaddxb Windows Customiser"
$form.Size = New-Object System.Drawing.Size(500, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Sizable"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# --- Main TabControl ---
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($tabControl)


#----------------------------------
# Tab: Remove Apps
#----------------------------------
$tabRemoveApps = New-Object System.Windows.Forms.TabPage
$tabRemoveApps.Text = "Remove Apps"
$tabControl.Controls.Add($tabRemoveApps)

$actionPanel_Remove = New-Object System.Windows.Forms.Panel
$actionPanel_Remove.Dock = [System.Windows.Forms.DockStyle]::Bottom
$actionPanel_Remove.Height = 50
$tabRemoveApps.Controls.Add($actionPanel_Remove)

$contentPanel_Remove = New-Object System.Windows.Forms.Panel
$contentPanel_Remove.Dock = [System.Windows.Forms.DockStyle]::Fill
$contentPanel_Remove.AutoScroll = $true
$tabRemoveApps.Controls.Add($contentPanel_Remove)

$appsGroupBox = New-Object System.Windows.Forms.GroupBox
$appsGroupBox.Location = [System.Drawing.Point]::new(10, 10)
$appsGroupBox.Text = "UWP App Management"
$contentPanel_Remove.Controls.Add($appsGroupBox)

$selectAllCheckbox = New-Object System.Windows.Forms.CheckBox
$selectAllCheckbox.Location = [System.Drawing.Point]::new(20, 30)
$selectAllCheckbox.Size = New-Object System.Drawing.Size(300, 20)
$selectAllCheckbox.Text = "Select All"
$selectAllCheckbox.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$appsGroupBox.Controls.Add($selectAllCheckbox)

$checkboxes = @()
$y = 55
foreach ($packageName in $packageMappings.Keys) {
    $friendlyName = $packageMappings[$packageName]
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = [System.Drawing.Point]::new(20, $y)
    $checkbox.Size = New-Object System.Drawing.Size(380, 20)
    $checkbox.Text = $friendlyName
    $appsGroupBox.Controls.Add($checkbox)
    $checkboxes += @{ Name = $packageName; Checkbox = $checkbox }
    $y += 22
}
$appsGroupBox.Size = [System.Drawing.Size]::new(425, $y + 15)

$removeButton = New-Object System.Windows.Forms.Button
$removeButton.Location = [System.Drawing.Point]::new(310, 10)
$removeButton.Size = New-Object System.Drawing.Size(100, 30)
$removeButton.Text = "Remove"
$actionPanel_Remove.Controls.Add($removeButton)

$refreshButton_Remove = New-Object System.Windows.Forms.Button
$refreshButton_Remove.Location = [System.Drawing.Point]::new(200, 10)
$refreshButton_Remove.Size = New-Object System.Drawing.Size(100, 30)
$refreshButton_Remove.Text = "Refresh"
$actionPanel_Remove.Controls.Add($refreshButton_Remove)

$selectAllCheckbox.Add_Click({ foreach ($checkboxInfo in $checkboxes) { $checkboxInfo.Checkbox.Checked = $selectAllCheckbox.Checked } })
$removeButton.Add_Click({ foreach ($checkboxInfo in $checkboxes) { if ($checkboxInfo.Checkbox.Checked) { $friendlyName = $packageMappings[$checkboxInfo.Name]; $package = Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $checkboxInfo.Name; if ($null -ne $package) { Write-Host "Removing the $friendlyName app..."; $package.PackageFullName | ForEach-Object { Remove-AppxPackage -Package $_ -AllUsers }; Write-Host "The $friendlyName app has been removed." } else { Write-Host "The $friendlyName app is not installed." } } }; RefreshCheckboxesRemoveApp })
$refreshButton_Remove.Add_Click({ RefreshCheckboxesRemoveApp })
RefreshCheckboxesRemoveApp


#----------------------------------
# Tab: Windows Tweaks
#----------------------------------
$tabWindowsTweaks = New-Object System.Windows.Forms.TabPage
$tabWindowsTweaks.Text = "Windows Tweaks"
$tabControl.Controls.Add($tabWindowsTweaks)

$tweaksActionPanel = New-Object System.Windows.Forms.Panel
$tweaksActionPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$tweaksActionPanel.Height = 50
$tabWindowsTweaks.Controls.Add($tweaksActionPanel)

$tweaksContentPanel = New-Object System.Windows.Forms.Panel
$tweaksContentPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$tweaksContentPanel.AutoScroll = $true
$tabWindowsTweaks.Controls.Add($tweaksContentPanel)

$tweaksGroupBox = New-Object System.Windows.Forms.GroupBox
$tweaksGroupBox.Location = [System.Drawing.Point]::new(10, 10)
$tweaksGroupBox.Text = "System & Explorer Tweaks"
$tweaksContentPanel.Controls.Add($tweaksGroupBox)

$checkboxesWindowsTweaks = @()
$yPos = 30
foreach ($tweakName in $windowsTweaksMapping.Keys) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $tweakName
    $checkbox.Location = [System.Drawing.Point]::new(20, $yPos)
    $checkbox.Width = 420
    $tweaksGroupBox.Controls.Add($checkbox)
    $checkboxesWindowsTweaks += $checkbox
    $yPos += 22
}
$tweaksGroupBox.Size = [System.Drawing.Size]::new(425, $yPos + 15)

$refreshButtonWindowsTweaks = New-Object System.Windows.Forms.Button
$refreshButtonWindowsTweaks.Text = "Refresh"; $refreshButtonWindowsTweaks.Location = [System.Drawing.Point]::new(200, 10); $refreshButtonWindowsTweaks.Size = New-Object System.Drawing.Size(100, 30)
$tweaksActionPanel.Controls.Add($refreshButtonWindowsTweaks)

$clearButtonWindowsTweaks = New-Object System.Windows.Forms.Button
$clearButtonWindowsTweaks.Text = "Clear Checks"; $clearButtonWindowsTweaks.Location = [System.Drawing.Point]::new(90, 10); $clearButtonWindowsTweaks.Size = New-Object System.Drawing.Size(100, 30)
$tweaksActionPanel.Controls.Add($clearButtonWindowsTweaks)

$applyButtonWindowsTweaks = New-Object System.Windows.Forms.Button
$applyButtonWindowsTweaks.Location = [System.Drawing.Point]::new(310, 10); $applyButtonWindowsTweaks.Size = New-Object System.Drawing.Size(100, 30); $applyButtonWindowsTweaks.Text = "Apply"
$tweaksActionPanel.Controls.Add($applyButtonWindowsTweaks)

$refreshButtonWindowsTweaks.Add_Click({ RefreshCheckboxesTweaks })
$clearButtonWindowsTweaks.Add_Click({ foreach ($checkbox in $checkboxesWindowsTweaks) { $checkbox.Checked = $false } })
$applyButtonWindowsTweaks.Add_Click({ foreach ($checkbox in $checkboxesWindowsTweaks) { if ($checkbox.Checked) { $tweakName = $checkbox.Text; if ($windowsTweaksMapping.ContainsKey($tweakName)) { & $windowsTweaksMapping[$tweakName] } } }; Write-Host "Restarting Windows Explorer to apply changes..."; Stop-Process -Name explorer -Force; Write-Host "Explorer restarted."; RefreshCheckboxesTweaks })
RefreshCheckboxesTweaks


#----------------------------------
# Tab: Install Apps
#----------------------------------
$tabInstallApps = New-Object System.Windows.Forms.TabPage
$tabInstallApps.Text = "Install Apps"
$tabControl.Controls.Add($tabInstallApps)

$buttonPanel_Install = New-Object System.Windows.Forms.Panel; $buttonPanel_Install.Dock = 'Bottom'; $buttonPanel_Install.Height = 50
$logPanel_Install = New-Object System.Windows.Forms.Panel; $logPanel_Install.Dock = 'Bottom'; $logPanel_Install.Height = 170
$contentPanel_Install = New-Object System.Windows.Forms.Panel; $contentPanel_Install.Dock = 'Fill'; $contentPanel_Install.AutoScroll = $true
$tabInstallApps.Controls.Add($contentPanel_Install); $tabInstallApps.Controls.Add($logPanel_Install); $tabInstallApps.Controls.Add($buttonPanel_Install)

$appsGroupBox_Install = New-Object System.Windows.Forms.GroupBox
$appsGroupBox_Install.Location = [System.Drawing.Point]::new(10, 10); $appsGroupBox_Install.Text = "Available Applications"
$contentPanel_Install.Controls.Add($appsGroupBox_Install)

$checkboxesInstallApps = @()
$yInstall = 30
foreach ($appName in $appsToInstallMapping.Keys) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = [System.Drawing.Point]::new(20, $yInstall); $checkbox.Size = New-Object System.Drawing.Size(380, 20); $checkbox.Text = $appName
    $appsGroupBox_Install.Controls.Add($checkbox)
    $checkboxesInstallApps += $checkbox
    $yInstall += 22
}
$appsGroupBox_Install.Size = [System.Drawing.Size]::new(425, $yInstall + 15)

$installButton = New-Object System.Windows.Forms.Button
$checkInstalledButton = New-Object System.Windows.Forms.Button
$checkInstalledButton.Location = [System.Drawing.Point]::new(210, 10); $checkInstalledButton.Size = New-Object System.Drawing.Size(120, 30); $checkInstalledButton.Text = "Check Installed"
$buttonPanel_Install.Controls.Add($checkInstalledButton)
$installButton.Location = [System.Drawing.Point]::new(340, 10); $installButton.Size = New-Object System.Drawing.Size(100, 30); $installButton.Text = "Install"
$buttonPanel_Install.Controls.Add($installButton)

$installLogBox = New-Object System.Windows.Forms.TextBox
$installStatusLabel = New-Object System.Windows.Forms.Label
$installLogBox.Location = [System.Drawing.Point]::new(10, 5); $installLogBox.Size = New-Object System.Drawing.Size(425, 125); $installLogBox.MultiLine = $true; $installLogBox.ScrollBars = 'Vertical'; $installLogBox.ReadOnly = $true; $installLogBox.Font = New-Object System.Drawing.Font("Consolas", 9); $installLogBox.Visible = $false
$logPanel_Install.Controls.Add($installLogBox)
$installStatusLabel.Location = [System.Drawing.Point]::new(10, 140); $installStatusLabel.Size = New-Object System.Drawing.Size(425, 20); $installStatusLabel.Text = ""
$logPanel_Install.Controls.Add($installStatusLabel)

$checkInstalledButton.Add_Click({ Update-InstalledAppCheckboxes_Synchronous -checkButton $checkInstalledButton -installButton $installButton -statusLabel $installStatusLabel -form $form })
$installButton.Add_Click({ $installStatusLabel.Text = "Starting installations..."; foreach ($checkbox in $checkboxesInstallApps) { if ($checkbox.Checked) { $appName = $checkbox.Text; $appId = $appsToInstallMapping[$appName]; $installStatusLabel.Text = "Installing $appName..."; $form.Update(); winget install --id $appId -e --accept-package-agreements --accept-source-agreements } }; $installStatusLabel.Text = "Installation process complete."; [System.Windows.Forms.MessageBox]::Show("Selected applications have been installed.", "Installation Complete") })


#----------------------------------
# Tab: Backup & Restore
#----------------------------------
$tabBackup = New-Object System.Windows.Forms.TabPage
$tabBackup.Text = "Backup & Restore"
$tabBackup.AutoScroll = $true
$tabControl.Controls.Add($tabBackup)

$backupRestoreItems = @("MobaXterm", "Syncthing", "FileZilla", "Fences", "Windows Sidebar", "Windows Terminal", "mkcerts", "JDownloader", "Input Director")

$backupGroupBox = New-Object System.Windows.Forms.GroupBox
$backupGroupBox.Location = [System.Drawing.Point]::new(10, 10); $backupGroupBox.Size = New-Object System.Drawing.Size(425, 290); $backupGroupBox.Text = "Backup"
$tabBackup.Controls.Add($backupGroupBox)

$backupCheckboxes = @(); $yBackup = 30
$selectAllBackupCheckbox = New-Object System.Windows.Forms.CheckBox; $selectAllBackupCheckbox.Location = [System.Drawing.Point]::new(20, $yBackup); $selectAllBackupCheckbox.Size = New-Object System.Drawing.Size(300, 20); $selectAllBackupCheckbox.Text = "Select All"; $selectAllBackupCheckbox.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold); $backupGroupBox.Controls.Add($selectAllBackupCheckbox); $yBackup += 25
$itemIndex = 0; $itemsInFirstColumn = 5
foreach ($item in $backupRestoreItems) {
    $xPos = 0; $yPos = 0
    if ($itemIndex -lt $itemsInFirstColumn) { $xPos = 40; $yPos = $yBackup + ($itemIndex * 20) } else { $xPos = 220; $yPos = $yBackup + (($itemIndex - $itemsInFirstColumn) * 20) }
    $checkbox = New-Object System.Windows.Forms.CheckBox; $checkbox.Location = [System.Drawing.Point]::new($xPos, $yPos); $checkbox.Size = New-Object System.Drawing.Size(180, 20); $checkbox.Text = $item
    $backupGroupBox.Controls.Add($checkbox); $backupCheckboxes += $checkbox; $itemIndex++
}
$selectAllBackupCheckbox.Add_Click({ foreach ($cb in $backupCheckboxes) { $cb.Checked = $selectAllBackupCheckbox.Checked } })

$yBackup = 160
$backupDestLabel = New-Object System.Windows.Forms.Label; $backupDestLabel.Location = [System.Drawing.Point]::new(10, $yBackup); $backupDestLabel.Size = New-Object System.Drawing.Size(400, 20); $backupDestLabel.Text = "Backup Destination:"; $backupGroupBox.Controls.Add($backupDestLabel); $yBackup += 20
$backupPathTextBox = New-Object System.Windows.Forms.TextBox; $backupPathTextBox.Location = [System.Drawing.Point]::new(10, $yBackup); $backupPathTextBox.Size = New-Object System.Drawing.Size(320, 20); $backupPathTextBox.ReadOnly = $true; $backupGroupBox.Controls.Add($backupPathTextBox)
$browseBackupButton = New-Object System.Windows.Forms.Button; $browseBackupButton.Location = [System.Drawing.Point]::new(340, $yBackup - 2); $browseBackupButton.Size = New-Object System.Drawing.Size(75, 25); $browseBackupButton.Text = "Browse..."; $backupGroupBox.Controls.Add($browseBackupButton); $yBackup += 30
$backupButton = New-Object System.Windows.Forms.Button; $backupButton.Location = [System.Drawing.Point]::new(150, $yBackup); $backupButton.Size = New-Object System.Drawing.Size(120, 30); $backupButton.Text = "Start Backup"; $backupButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold); $backupGroupBox.Controls.Add($backupButton)
$backupProgressBar = New-Object System.Windows.Forms.ProgressBar; $backupProgressBar.Location = [System.Drawing.Point]::new(10, $yBackup + 40); $backupProgressBar.Size = New-Object System.Drawing.Size(405, 20); $backupGroupBox.Controls.Add($backupProgressBar)
$backupStatusLabel = New-Object System.Windows.Forms.Label; $backupStatusLabel.Location = [System.Drawing.Point]::new(10, $yBackup + 65); $backupStatusLabel.AutoSize = $true; $backupStatusLabel.Text = "Select items and destination."; $backupGroupBox.Controls.Add($backupStatusLabel)

$restoreGroupBox = New-Object System.Windows.Forms.GroupBox
$restoreGroupBox.Location = [System.Drawing.Point]::new(10, 310); $restoreGroupBox.Size = New-Object System.Drawing.Size(425, 290); $restoreGroupBox.Text = "Restore"
$tabBackup.Controls.Add($restoreGroupBox)

$restoreCheckboxes = @(); $yRestore = 30
$selectAllRestoreCheckbox = New-Object System.Windows.Forms.CheckBox; $selectAllRestoreCheckbox.Location = [System.Drawing.Point]::new(20, $yRestore); $selectAllRestoreCheckbox.Size = New-Object System.Drawing.Size(300, 20); $selectAllRestoreCheckbox.Text = "Select All"; $selectAllRestoreCheckbox.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold); $restoreGroupBox.Controls.Add($selectAllRestoreCheckbox); $yRestore += 25
$itemIndex = 0
foreach ($item in $backupRestoreItems) {
    $xPos = 0; $yPos = 0
    if ($itemIndex -lt $itemsInFirstColumn) { $xPos = 40; $yPos = $yRestore + ($itemIndex * 20) } else { $xPos = 220; $yPos = $yRestore + (($itemIndex - $itemsInFirstColumn) * 20) }
    $checkbox = New-Object System.Windows.Forms.CheckBox; $checkbox.Location = [System.Drawing.Point]::new($xPos, $yPos); $checkbox.Size = New-Object System.Drawing.Size(180, 20); $checkbox.Text = $item
    $restoreGroupBox.Controls.Add($checkbox); $restoreCheckboxes += $checkbox; $itemIndex++
}
$selectAllRestoreCheckbox.Add_Click({ foreach ($cb in $restoreCheckboxes) { $cb.Checked = $selectAllRestoreCheckbox.Checked } })

$yRestore = 160
$restoreDestLabel = New-Object System.Windows.Forms.Label; $restoreDestLabel.Location = [System.Drawing.Point]::new(10, $yRestore); $restoreDestLabel.Size = New-Object System.Drawing.Size(400, 20); $restoreDestLabel.Text = "Restore From (select parent folder):"; $restoreGroupBox.Controls.Add($restoreDestLabel); $yRestore += 20
$restorePathTextBox = New-Object System.Windows.Forms.TextBox; $restorePathTextBox.Location = [System.Drawing.Point]::new(10, $yRestore); $restorePathTextBox.Size = New-Object System.Drawing.Size(320, 20); $restorePathTextBox.ReadOnly = $true; $restoreGroupBox.Controls.Add($restorePathTextBox)
$browseRestoreButton = New-Object System.Windows.Forms.Button; $browseRestoreButton.Location = [System.Drawing.Point]::new(340, $yRestore - 2); $browseRestoreButton.Size = New-Object System.Drawing.Size(75, 25); $browseRestoreButton.Text = "Browse..."; $restoreGroupBox.Controls.Add($browseRestoreButton); $yRestore += 30
$restoreButton = New-Object System.Windows.Forms.Button; $restoreButton.Location = [System.Drawing.Point]::new(150, $yRestore); $restoreButton.Size = New-Object System.Drawing.Size(120, 30); $restoreButton.Text = "Start Restore"; $restoreButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold); $restoreGroupBox.Controls.Add($restoreButton)
$restoreProgressBar = New-Object System.Windows.Forms.ProgressBar; $restoreProgressBar.Location = [System.Drawing.Point]::new(10, $yRestore + 40); $restoreProgressBar.Size = New-Object System.Drawing.Size(405, 20); $restoreGroupBox.Controls.Add($restoreProgressBar)
$restoreStatusLabel = New-Object System.Windows.Forms.Label; $restoreStatusLabel.Location = [System.Drawing.Point]::new(10, $yRestore + 65); $restoreStatusLabel.AutoSize = $true; $restoreStatusLabel.Text = "Select items and source."; $restoreGroupBox.Controls.Add($restoreStatusLabel)

$browseBackupButton.Add_Click({ try { $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; if ($folderBrowser.ShowDialog() -eq "OK") { $backupPathTextBox.Text = $folderBrowser.SelectedPath } } catch { [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error") } })
$browseRestoreButton.Add_click({ try { $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; if ($folderBrowser.ShowDialog() -eq "OK") { $selectedPath = $folderBrowser.SelectedPath; $restorePathTextBox.Text = $selectedPath; if (-not $allBackupTasks) { $restoreStatusLabel.Text = "Error: Backup config not loaded."; return }; $backupSourceRoot = Get-ChildItem -Path (Join-Path -Path $selectedPath -ChildPath "backups") -Directory -ErrorAction SilentlyContinue | Select-Object -First 1; if ($backupSourceRoot) { foreach ($checkbox in $restoreCheckboxes) { $checkbox.Checked = $false; $appName = $checkbox.Text; $taskData = $allBackupTasks[$appName]; if ($taskData) { $expectedBackupPath = ""; if ($taskData.Export) { $expectedBackupPath = Join-Path -Path $backupSourceRoot.FullName -ChildPath $appName } else { $mangledPathName = ($taskData.Path -replace ':', ''); $expectedBackupPath = Join-Path -Path $backupSourceRoot.FullName -ChildPath $mangledPathName }; if (Test-Path -Path $expectedBackupPath) { $checkbox.Checked = $true } } } } else { foreach ($checkbox in $restoreCheckboxes) { $checkbox.Checked = $false } } } } catch { [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error") } })
$backupButton.Add_Click({ $selectedTasks = $backupCheckboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Text }; if ($selectedTasks.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Please select at least one item to back up.", "Error"); return }; if ([string]::IsNullOrWhiteSpace($backupPathTextBox.Text)) { [System.Windows.Forms.MessageBox]::Show("Please select a backup destination.", "Error"); return }; Start-AppBackup -baseDestination $backupPathTextBox.Text -selectedTasks $selectedTasks -statusLabel $backupStatusLabel -progressBar $backupProgressBar -form $form })
$restoreButton.Add_Click({ $selectedTasks = $restoreCheckboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Text }; if ($selectedTasks.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Please select at least one item to restore.", "Error"); return }; if ([string]::IsNullOrWhiteSpace($restorePathTextBox.Text)) { [System.Windows.Forms.MessageBox]::Show("Please select the source backup folder.", "Error"); return }; Start-AppRestore -baseBackupPath $restorePathTextBox.Text -selectedTasks $selectedTasks -statusLabel $restoreStatusLabel -progressBar $restoreProgressBar -form $form })


#==================================================================
# SHOW FORM
#==================================================================
$form.ShowDialog() | Out-Null