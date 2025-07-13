$tabWindowsTweaks = New-Object System.Windows.Forms.TabPage
$tabWindowsTweaks.Text = "Windows Tweaks"
$tabControl.Controls.Add($tabWindowsTweaks)

# --- 1. Create a Panel for the Buttons (at the bottom) ---
$tweaksActionPanel = New-Object System.Windows.Forms.Panel
$tweaksActionPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$tweaksActionPanel.Height = 50
$tabWindowsTweaks.Controls.Add($tweaksActionPanel)

# --- 2. Create a Panel for the Content (fills the rest of the space) ---
$tweaksContentPanel = New-Object System.Windows.Forms.Panel
$tweaksContentPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$tweaksContentPanel.AutoScroll = $true # This panel will handle scrolling
$tabWindowsTweaks.Controls.Add($tweaksContentPanel)

# --- 3. Create a GroupBox to contain the tweaks ---
$tweaksGroupBox = New-Object System.Windows.Forms.GroupBox
$tweaksGroupBox.Location = [System.Drawing.Point]::new(10, 10)
$tweaksGroupBox.Text = "System & Explorer Tweaks"
$tweaksContentPanel.Controls.Add($tweaksGroupBox)

# --- 4. Add Content to the GroupBox ---
$checkboxesWindowsTweaks = @()
$yPos = 30 # Start Y position inside the GroupBox
foreach ($tweakName in $windowsTweaksMapping.Keys) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $tweakName
    $checkbox.Location = [System.Drawing.Point]::new(20, $yPos) # Moved left
    $checkbox.Width = 410 # Keep width to prevent text cutoff
    $tweaksGroupBox.Controls.Add($checkbox)
    $checkboxesWindowsTweaks += $checkbox
    $yPos += 22 # Use tight spacing
}

# Dynamically set the height of the GroupBox to fit its content
$tweaksGroupBox.Size = [System.Drawing.Size]::new(435, $yPos + 15)


# --- 5. Add Buttons to the FIXED Action Panel ---
$refreshButtonWindowsTweaks = New-Object System.Windows.Forms.Button
$refreshButtonWindowsTweaks.Text = "Refresh"
$refreshButtonWindowsTweaks.Location = [System.Drawing.Point]::new(200, 10)
$refreshButtonWindowsTweaks.Size = New-Object System.Drawing.Size(100, 30)
$tweaksActionPanel.Controls.Add($refreshButtonWindowsTweaks)

$clearButtonWindowsTweaks = New-Object System.Windows.Forms.Button
$clearButtonWindowsTweaks.Text = "Clear Checks"
$clearButtonWindowsTweaks.Location = [System.Drawing.Point]::new(90, 10)
$clearButtonWindowsTweaks.Size = New-Object System.Drawing.Size(100, 30)
$tweaksActionPanel.Controls.Add($clearButtonWindowsTweaks)

$applyButtonWindowsTweaks = New-Object System.Windows.Forms.Button
$applyButtonWindowsTweaks.Location = [System.Drawing.Point]::new(310, 10)
$applyButtonWindowsTweaks.Size = New-Object System.Drawing.Size(100, 30)
$applyButtonWindowsTweaks.Text = "Apply"
$tweaksActionPanel.Controls.Add($applyButtonWindowsTweaks)

# --- 6. Button Click Logic ---
$refreshButtonWindowsTweaks.Add_Click({ RefreshCheckboxesTweaks })
$clearButtonWindowsTweaks.Add_Click({ foreach ($checkbox in $checkboxesWindowsTweaks) { $checkbox.Checked = $false } })
$applyButtonWindowsTweaks.Add_Click({
    foreach ($checkbox in $checkboxesWindowsTweaks) {
        if ($checkbox.Checked) {
            $tweakName = $checkbox.Text
            if ($windowsTweaksMapping.ContainsKey($tweakName)) { & $windowsTweaksMapping[$tweakName] }
        }
    }
    Write-Host "Restarting Windows Explorer to apply changes..."
    Stop-Process -Name explorer -Force
    Write-Host "Explorer restarted."
    RefreshCheckboxesTweaks
})

# Initial check
RefreshCheckboxesTweaks