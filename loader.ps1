<#
.SYNOPSIS
    Downloads a multi-file PowerShell project from GitHub, combines it into a single script,
    and executes it in memory. This is designed to be run as a one-liner.
#>

# --- CONFIGURATION ---
# Make sure these match your GitHub username and repository name
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
    # Define the files in logical groups to ensure correct loading order.
    $configFiles = @(
        "config/RemoveApps.config.ps1",
        "config/WindowsTweaks.config.ps1",
        "config/InstallApps.config.ps1"
    )
    $functionFiles = @(
        "functions/App-Removal.functions.ps1",
        "functions/Tweak-Checks.functions.ps1",
        "functions/Backup.functions.ps1",
        "functions/App-Install.functions.ps1"
    )
    $tabFiles = @(
        "tabs/Tab.RemoveApps.ps1",
        "tabs/Tab.WindowsTweaks.ps1",
        "tabs/Tab.InstallApps.ps1",
        "tabs/Tab.Backup.ps1"
    )

    Write-Host "Combining script files..."
    
    # Start with the mandatory header
    $combinedScript = @"
#----------------------------------
#  AUTO-GENERATED SINGLE-FILE SCRIPT
#----------------------------------
Add-Type -AssemblyName System.Windows.Forms
"@

    # Helper function to append file content to the main script string
    function Append-FileContent($fileRelativePath, [ref]$scriptString) {
        $filePath = Join-Path $projectRoot $fileRelativePath
        if (Test-Path $filePath) {
            $scriptString.Value += "`n# --- From File: $fileRelativePath ---`n"
            $scriptString.Value += (Get-Content -Path $filePath -Raw)
        } else {
            Write-Warning "Could not find file: $filePath"
        }
    }

    # 1. Append all Configurations
    $configFiles | ForEach-Object { Append-FileContent -fileRelativePath $_ -scriptString ([ref]$combinedScript) }

    # 2. Append all Functions
    $functionFiles | ForEach-Object { Append-FileContent -fileRelativePath $_ -scriptString ([ref]$combinedScript) }

    # 3. Manually add the core UI creation code BEFORE the tabs
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
    $tabFiles | ForEach-Object { Append-FileContent -fileRelativePath $_ -scriptString ([ref]$combinedScript) }

    # 5. Append the final execution command
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
