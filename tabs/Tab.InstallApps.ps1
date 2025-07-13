$tabInstallApps = New-Object System.Windows.Forms.TabPage
$tabInstallApps.Text = "Install Apps"
$tabInstallApps.BackColor = $theme.Background
$tabControl.Controls.Add($tabInstallApps)

# --- 1. Create the three main panels for the layout ---
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$buttonPanel.Height = 50 # Slim panel just for buttons
$buttonPanel.BackColor = $theme.Background

$logPanel = New-Object System.Windows.Forms.Panel
$logPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$logPanel.Height = 170 # Panel for the log box and status
$logPanel.BackColor = $theme.Background

$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$contentPanel.AutoScroll = $true # Panel for the scrolling checkboxes
$contentPanel.BackColor = $theme.Background

# --- 2. Add panels to the tab. Order matters for docking. ---
$tabInstallApps.Controls.Add($contentPanel)
$tabInstallApps.Controls.Add($logPanel)
$tabInstallApps.Controls.Add($buttonPanel)

# --- 3. Create and add controls to the CONTENT panel ---
$appsGroupBox = New-Object System.Windows.Forms.GroupBox
$appsGroupBox.Location = [System.Drawing.Point]::new(10, 10)
$appsGroupBox.Text = "Available Applications"
$appsGroupBox.ForeColor = $theme.Foreground
$appsGroupBox.Font = $theme.Font
$contentPanel.Controls.Add($appsGroupBox)

$checkboxesInstallApps = @()
$yInstall = 30
foreach ($appName in $appsToInstallMapping.Keys) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = [System.Drawing.Point]::new(20, $yInstall)
    $checkbox.Size = New-Object System.Drawing.Size(380, 20)
    $checkbox.Text = $appName
    $checkbox.ForeColor = $theme.Foreground
    $checkbox.Font = $theme.Font
    $appsGroupBox.Controls.Add($checkbox)
    $checkboxesInstallApps += $checkbox
    $yInstall += 22
}
$appsGroupBox.Size = [System.Drawing.Size]::new(435, $yInstall + 15)


# --- 4. Create and add controls to the BUTTON panel ---
$installButton = New-Object System.Windows.Forms.Button
$checkInstalledButton = New-Object System.Windows.Forms.Button

$checkInstalledButton.Location = [System.Drawing.Point]::new(210, 10)
$checkInstalledButton.Size = New-Object System.Drawing.Size(120, 30)
$checkInstalledButton.Text = "Check Installed"
$checkInstalledButton.BackColor = $theme.Control
$checkInstalledButton.ForeColor = $theme.Foreground
$checkInstalledButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonPanel.Controls.Add($checkInstalledButton)

$installButton.Location = [System.Drawing.Point]::new(340, 10)
$installButton.Size = New-Object System.Drawing.Size(100, 30)
$installButton.Text = "Install"
$installButton.BackColor = $theme.Accent
$installButton.ForeColor = $theme.Foreground
$installButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonPanel.Controls.Add($installButton)

# --- 5. Create and add controls to the LOG panel ---
$installLogBox = New-Object System.Windows.Forms.TextBox
$installStatusLabel = New-Object System.Windows.Forms.Label

$installLogBox.Location = [System.Drawing.Point]::new(10, 5)
$installLogBox.Size = New-Object System.Drawing.Size(435, 125)
$installLogBox.MultiLine = $true
$installLogBox.ScrollBars = 'Vertical'
$installLogBox.ReadOnly = $true
$installLogBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$installLogBox.BackColor = $theme.Control
$installLogBox.ForeColor = $theme.Foreground
$installLogBox.Visible = $false
$logPanel.Controls.Add($installLogBox)

$installStatusLabel.Location = [System.Drawing.Point]::new(10, 140)
$installStatusLabel.Size = New-Object System.Drawing.Size(435, 20)
$installStatusLabel.Text = ""
$installStatusLabel.ForeColor = $theme.Foreground
$logPanel.Controls.Add($installStatusLabel)

# --- 6. Button Click Logic ---
$checkInstalledButton.Add_Click({
    # The 'freezing' solution is already implemented in the function file
    Update-InstalledAppCheckboxes_Synchronous -checkButton $checkInstalledButton -installButton $installButton -statusLabel $installStatusLabel -form $form
})

$installButton.Add_Click({
    $installStatusLabel.Text = "Starting installations..."
    $failedApps = [System.Collections.Generic.List[string]]::new()

    foreach ($checkbox in $checkboxesInstallApps) {
        if ($checkbox.Checked) {
            $appName = $checkbox.Text
            $appId = $appsToInstallMapping[$appName]
            $installStatusLabel.Text = "Installing $appName..."
            $form.Update()
            try {
                winget install --id $appId -e --accept-package-agreements --accept-source-agreements
            }
            catch {
                $failedApps.Add($appName)
            }
        }
    }

    if ($failedApps.Count -gt 0) {
        $failedList = $failedApps -join "`n- "
        [System.Windows.Forms.MessageBox]::Show("The following apps failed to install:`n- $failedList`n`nPlease check the logs for more details.", "Installation Failures", "OK", "Warning")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Selected applications have been installed.", "Installation Complete")
    }

    $installStatusLabel.Text = "Installation process complete."
})