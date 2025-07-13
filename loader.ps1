<#
.SYNOPSIS
    Downloads a multi-file PowerShell project from GitHub, combines it into a single script,
    and executes it in memory. This version includes extensive logging to debug loading issues.
#>

# --- CONFIGURATION ---
$githubUser = "ahmaddxb"
$repoName   = "Ahmad-PC-Customiser"
$branchName = "master" # Change this to "main" if that is your repository's default branch
# --- END CONFIGURATION ---

# Define URLs and temporary paths
$zipUrl   = "https://github.com/$githubUser/$repoName/archive/refs/heads/$branchName.zip"
$tempDir  = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
$zipFile  = Join-Path $tempDir "repo.zip"

# Create a temporary directory for the download
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Download and extract the project
    Write-Host "Downloading project from GitHub..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "Extracting script files..."
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
    $unzippedFolder = Get-ChildItem -Path $tempDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if (-not $unzippedFolder) { throw "Could not find unzipped repository folder." }
    $projectRoot = $unzippedFolder.FullName
    Write-Host "Project extracted to: $projectRoot"

    # --- SCRIPT COMBINER LOGIC ---
    Write-Host "Combining script files..."
    
    $combinedScript = @"
#----------------------------------
#  AUTO-GENERATED SINGLE-FILE SCRIPT
#----------------------------------
Add-Type -AssemblyName System.Windows.Forms
"@

    # Helper function for verbose appending
    function Append-FileContent($fileRelativePath, [ref]$scriptString) {
        $filePath = Join-Path $projectRoot $fileRelativePath
        if (Test-Path $filePath) {
            Write-Host "Appending: $fileRelativePath"
            $scriptString.Value += "`n# --- From File: $fileRelativePath ---`n"
            $scriptString.Value += (Get-Content -Path $filePath -Raw)
        } else {
            Write-Warning "Could not find file: $filePath"
        }
    }

    # 1. Append Configurations
    Append-FileContent -fileRelativePath "config/RemoveApps.config.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "config/WindowsTweaks.config.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "config/InstallApps.config.ps1" -scriptString ([ref]$combinedScript)

    # 2. Append all Functions
    Append-FileContent -fileRelativePath "functions/App-Removal.functions.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "functions/Tweak-Checks.functions.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "functions/Backup.functions.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "functions/App-Install.functions.ps1" -scriptString ([ref]$combinedScript)

    # 3. Manually add the core UI creation code BEFORE the tabs
    Write-Host "Appending: Main Form and TabControl creation"
    $combinedScript += @"

# --- Main UI Creation ---
`$form = New-Object System.Windows.Forms.Form
`$form.Text = "Ahmaddxb Windows Customiser"
`$form.Size = New-Object System.Drawing.Size(500, 850)
`$form.StartPosition = "CenterScreen"
`$form.FormBorderStyle = "Sizable"
`$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

`$tabControl = New-Object System.Windows.Forms.TabControl
`$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
`$form.Controls.Add(`$tabControl)
"@

    # 4. Append all Tab UI files
    Append-FileContent -fileRelativePath "tabs/Tab.RemoveApps.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "tabs/Tab.WindowsTweaks.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "tabs/Tab.InstallApps.ps1" -scriptString ([ref]$combinedScript)
    Append-FileContent -fileRelativePath "tabs/Tab.Backup.ps1" -scriptString ([ref]$combinedScript)

    # 5. Append the final execution command
    Write-Host "Appending: Final ShowDialog() call"
    $combinedScript += @"

# --- Show the Form ---
`$form.ShowDialog() | Out-Null
"@

    Write-Host "Executing main application..."
    # Execute the final combined script
    Invoke-Expression -Command $combinedScript

}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
finally {
    # Clean up the temporary directory and ZIP file
    Write-Host "Cleaning up temporary files..."
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
