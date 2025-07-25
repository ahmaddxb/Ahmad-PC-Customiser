function Update-InstalledAppCheckboxes_Synchronous {
    param(
        [System.Windows.Forms.Button]$checkButton,
        [System.Windows.Forms.Button]$installButton,
        [System.Windows.Forms.Label]$statusLabel,
        [System.Windows.Forms.Form]$form # Pass the main form to force UI updates
    )

    # --- Step 1: Disable UI and provide feedback before freezing ---
    $checkButton.Enabled = $false
    $installButton.Enabled = $false
    $statusLabel.Text = "Checking... The app will now freeze."
    # Force the UI to repaint the label before the loop starts.
    $form.Update()

    # --- Step 2: Run the synchronous, freezing check ---
    foreach ($checkbox in $checkboxesInstallApps) {
        $appName = $checkbox.Text
        $appId = $appsToInstallMapping[$appName]
        
        # This command runs slowly for each app, causing the freeze.
        $isInstalled = winget list --id $appId --accept-source-agreements | Select-String -Pattern $appId -Quiet
        
        $checkbox.Checked = $isInstalled
    }

    # --- Step 3: Re-enable UI after the check is complete ---
    $statusLabel.Text = "Check complete."
    $checkButton.Enabled = $true
    $installButton.Enabled = $true
}