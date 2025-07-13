$tabRemoveApps = New-Object System.Windows.Forms.TabPage
$tabRemoveApps.Text = "Remove Apps"
$tabRemoveApps.BackColor = $theme.Background
$tabControl.Controls.Add($tabRemoveApps)

# --- 1. Create a Panel for the Buttons (at the bottom) ---
$actionPanel = New-Object System.Windows.Forms.Panel
$actionPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$actionPanel.Height = 50
$actionPanel.BackColor = $theme.Background
$tabRemoveApps.Controls.Add($actionPanel)

# --- 2. Create a Panel for the Content (fills the rest of the space) ---
$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$contentPanel.AutoScroll = $true # This panel will handle scrolling
$contentPanel.BackColor = $theme.Background
$tabRemoveApps.Controls.Add($contentPanel)

# --- 3. Create a GroupBox to contain the app list ---
$appsGroupBox = New-Object System.Windows.Forms.GroupBox
$appsGroupBox.Location = [System.Drawing.Point]::new(10, 10)
$appsGroupBox.Text = "UWP App Management"
$appsGroupBox.ForeColor = $theme.Foreground
$appsGroupBox.Font = $theme.Font
$contentPanel.Controls.Add($appsGroupBox)

# --- 4. Add Content to the GroupBox ---
# The old title label is no longer needed.

$selectAllCheckbox = New-Object System.Windows.Forms.CheckBox
$selectAllCheckbox.Location = [System.Drawing.Point]::new(20, 30) #<-- Moved left
$selectAllCheckbox.Size = New-Object System.Drawing.Size(300, 20)
$selectAllCheckbox.Text = "Select All"
$selectAllCheckbox.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$selectAllCheckbox.ForeColor = $theme.Foreground
$appsGroupBox.Controls.Add($selectAllCheckbox)

$checkboxes = @()
$y = 55 # Start Y position below "Select All"
foreach ($packageName in $packageMappings.Keys) {
    $friendlyName = $packageMappings[$packageName]
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = [System.Drawing.Point]::new(20, $y) #<-- Moved left
    $checkbox.Size = New-Object System.Drawing.Size(380, 20)
    $checkbox.Text = $friendlyName
    $checkbox.ForeColor = $theme.Foreground
    $checkbox.Font = $theme.Font
    $appsGroupBox.Controls.Add($checkbox)
    $checkboxes += @{ Name = $packageName; Checkbox = $checkbox }
    $y += 22 # Use tighter spacing
}

# Dynamically set the height of the GroupBox to fit its content
$appsGroupBox.Size = [System.Drawing.Size]::new(435, $y + 15)

# --- 5. Add Buttons to the FIXED Action Panel ---
$removeButton = New-Object System.Windows.Forms.Button
$removeButton.Location = [System.Drawing.Point]::new(310, 10)
$removeButton.Size = New-Object System.Drawing.Size(100, 30)
$removeButton.Text = "Remove"
$removeButton.BackColor = $theme.Accent
$removeButton.ForeColor = $theme.Foreground
$removeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$actionPanel.Controls.Add($removeButton)

$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Location = [System.Drawing.Point]::new(200, 10)
$refreshButton.Size = New-Object System.Drawing.Size(100, 30)
$refreshButton.Text = "Refresh"
$refreshButton.BackColor = $theme.Control
$refreshButton.ForeColor = $theme.Foreground
$refreshButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$actionPanel.Controls.Add($refreshButton)

# --- 6. Button Click Logic ---
$selectAllCheckbox.Add_Click({
    foreach ($checkboxInfo in $checkboxes) { $checkboxInfo.Checkbox.Checked = $selectAllCheckbox.Checked }
})

$removeButton.Add_Click({
    $failedApps = [System.Collections.Generic.List[string]]::new()
    foreach ($checkboxInfo in $checkboxes) {
        if ($checkboxInfo.Checkbox.Checked) {
            $friendlyName = $packageMappings[$checkboxInfo.Name]
            try {
                $package = Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $checkboxInfo.Name
                if ($null -ne $package) {
                    Write-Host "Removing the $friendlyName app..."
                    $package.PackageFullName | ForEach-Object { Remove-AppxPackage -Package $_ -AllUsers }
                    Write-Host "The $friendlyName app has been removed."
                }
                else { Write-Host "The $friendlyName app is not installed." }
            }
            catch {
                $failedApps.Add($friendlyName)
            }
        }
    }

    if ($failedApps.Count -gt 0) {
        $failedList = $failedApps -join "`n- "
        [System.Windows.Forms.MessageBox]::Show("The following apps failed to uninstall:`n- $failedList`n`nPlease check your permissions and try again.", "Removal Failures", "OK", "Warning")
    } else {
        [System.Windows.Forms.MessageBox]::Show("All selected apps have been removed successfully.", "Success", "OK", "Information")
    }
    RefreshCheckboxesRemoveApp
})

$refreshButton.Add_Click({ RefreshCheckboxesRemoveApp })

# Initial check
RefreshCheckboxesRemoveApp