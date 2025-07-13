# This version has the corrected quotation marks for the -Command argument.
$tabJobTest = New-Object System.Windows.Forms.TabPage
$tabJobTest.Text = "Job Test"
$tabRemoveApps.AutoScroll = $true
$tabControl.Controls.Add($tabJobTest)

$testTitleLabel = New-Object System.Windows.Forms.Label
$testTitleLabel.Location = [System.Drawing.Point]::new(20, 20)
$testTitleLabel.Size = New-Object System.Drawing.Size(400, 30)
$testTitleLabel.Text = "Final Background Command Test"
$testTitleLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$tabJobTest.Controls.Add($testTitleLabel)

$testButton = New-Object System.Windows.Forms.Button
$testButton.Location = [System.Drawing.Point]::new(20, 60)
$testButton.Size = New-Object System.Drawing.Size(120, 30)
$testButton.Text = "Start Final Test"
$tabJobTest.Controls.Add($testButton)

$testLogBox = New-Object System.Windows.Forms.TextBox
$testLogBox.Location = [System.Drawing.Point]::new(20, 100)
$testLogBox.Size = New-Object System.Drawing.Size(410, 300)
$testLogBox.MultiLine = $true
$testLogBox.ScrollBars = 'Vertical'
$testLogBox.ReadOnly = $true
$testLogBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$tabJobTest.Controls.Add($testLogBox)

$testButton.Add_Click({
    $testButton.Enabled = $false
    $testLogBox.Text = "--- FINAL DEBUG TEST ---`r`n"
    
    $logFile = "C:\Temp\DebugTest.txt"
    $testLogBox.AppendText("1. Will attempt to write to: `"$logFile`"`r`n")
    
    if (-not (Test-Path -Path "C:\Temp")) { New-Item -Path "C:\Temp" -ItemType Directory }
    if (Test-Path -Path $logFile) { Remove-Item -Path $logFile -Force }

    # --- THIS IS THE CORRECTED LINE ---
    # We wrap the text in single quotes so it's treated as one string by the new PowerShell process.
    $command = "'Hello from background process' | Out-File -FilePath '$logFile' -Encoding UTF8"

    $argumentList = "-ExecutionPolicy Bypass -NoProfile -NoExit -Command $command"
    $testLogBox.AppendText("2. Assembled arguments: $argumentList`r`n")

    $testLogBox.AppendText("3. Launching VISIBLE PowerShell process...`r`n")
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList $argumentList
        $testLogBox.AppendText("4. Command sent. Please manually check for the file.`r`n")
    }
    catch {
        $testLogBox.AppendText("ERROR: Start-Process failed!`r`n")
        $testLogBox.AppendText($_.Exception.Message)
    }
    $testButton.Enabled = $true
})