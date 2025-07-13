<#
.SYNOPSIS
    Downloads a multi-file PowerShell project from GitHub, combines it into a single script,
    and executes it in memory. This is designed to be run as a one-liner.
#>

# --- CONFIGURATION ---
# Make sure these match your GitHub username and repository name
$githubUser = "ahmaddxb"
$repoName   = "Ahmad-PC-Customiser"
$branchName = "master" # Change this to "main" if that is your default branch
# --- END CONFIGURATION ---

# Define URLs and temporary paths
$zipUrl   = "https://github.com/$githubUser/$repoName/archive/refs/heads/$branchName.zip"
$tempDir  = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
$zipFile  = Join-Path $tempDir "repo.zip"

# Create a temporary directory for the download
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Download the entire repository as a ZIP file
    Write-Host "Downloading project from GitHub..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing

    # Extract the ZIP file
    Write-Host "Extracting script files..."
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force

    # The unzipped folder will have a name like 'RepoName-main' or 'RepoName-master'. Find it.
    $unzippedFolder = Get-ChildItem -Path $tempDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    
    if (-not $unzippedFolder) {
        throw "Could not find unzipped repository folder."
    }
    
    $projectRoot = $unzippedFolder.FullName
    Write-Host "Project extracted to: $projectRoot"

    # --- SCRIPT COMBINER LOGIC ---
    # Define the exact order in which to combine the script files.
    # This order is critical for the script to work correctly.
    $filesToCombine = @(
        # Configurations must come first
        "config/RemoveApps.config.ps1",
        "config/WindowsTweaks.config.ps1",
        "config/InstallApps.config.ps1",
        # Then all functions
        "functions/App-Removal.functions.ps1",
        "functions/Tweak-Checks.functions.ps1",
        "functions/Backup.functions.ps1",
        "functions/App-Install.functions.ps1",
        # Then the main UI elements from Main.ps1 (which we will add manually below)
        # Then the individual tabs
        "tabs/Tab.RemoveApps.ps1",
        "tabs/Tab.WindowsTweaks.ps1",
        "tabs/Tab.InstallApps.ps1",
        "tabs/Tab.Backup.ps1"
    )

    # Start building the final, single script string
    Write-Host "Combining script files..."
    
    # Start with the mandatory header
    $combinedScript = @"
#----------------------------------
#  AUTO-GENERATED SINGLE-FILE SCRIPT
#----------------------------------
#requires -version 5.1
#requires -runasadministrator

# The admin check is handled by the loader, so it is not needed here.

Add-Type -AssemblyName System.Windows.Forms

"@

    # Append the content of each file in the specified order
    foreach ($file in $filesToCombine) {
        $filePath = Join-Path $projectRoot $file
        if (Test-Path $filePath) {
            $combinedScript += "`n# --- From File: $file ---`n"
            $combinedScript += Get-Content -Path $filePath -Raw
        } else {
            Write-Warning "Could not find file: $filePath"
        }
    }

    # Manually add the core UI creation and the final ShowDialog() call
    $combinedScript += @"

# --- Main UI Creation and Execution ---
`$form = New-Object System.Windows.Forms.Form
`$form.Text = "Ahmaddxb Windows Customiser"
`$form.Size = New-Object System.Drawing.Size(500, 850)
`$form.StartPosition = "CenterScreen"
`$form.FormBorderStyle = "Sizable"
`$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

`$tabControl = New-Object System.Windows.Forms.TabControl
`$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
`$form.Controls.Add(`$tabControl)

# The individual tab scripts have already been loaded, so they will now add themselves to `$tabControl`
# when this combined script is executed.

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
