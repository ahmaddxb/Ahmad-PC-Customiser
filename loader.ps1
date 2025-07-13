<#
.SYNOPSIS
    This loader script downloads the latest version of a multi-file project from GitHub,
    extracts it, and runs the main application. It is designed to be called by a
    one-liner command that includes a cache-busting parameter.
#>

# --- CONFIGURATION ---
# Make sure these match your GitHub username and repository name.
$githubUser = "ahmaddxb"
$repoName   = "Ahmad-PC-Customiser"
$branchName = "master" # IMPORTANT: Change this to "main" if that is your repository's default branch.
# --- END CONFIGURATION ---

# Define URLs and temporary paths
$zipUrl   = "https://github.com/$githubUser/$repoName/archive/refs/heads/$branchName.zip"
$tempDir  = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
$zipFile  = Join-Path $tempDir "repo.zip"

# Create a temporary directory for the download
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Download the entire repository as a ZIP file
    Write-Host "Downloading latest project version from GitHub..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing

    # Extract the ZIP file
    Write-Host "Extracting script files..."
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force

    # The unzipped folder will have a name like 'RepoName-main' or 'RepoName-master'. Find it.
    $unzippedFolder = Get-ChildItem -Path $tempDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    
    if (-not $unzippedFolder) {
        throw "Could not find the unzipped repository folder inside the temporary directory."
    }
    
    $projectRoot = $unzippedFolder.FullName
    Write-Host "Project extracted to: $projectRoot"

    # Define the path to the real Main.ps1 script
    $scriptPath = Join-Path $projectRoot "Main.ps1"

    if (Test-Path $scriptPath) {
        Write-Host "Executing main application..."
        # Launch the main script from the extracted folder
        & $scriptPath
    } else {
        throw "Could not find Main.ps1 in the downloaded archive."
    }
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
finally {
    # Clean up the temporary directory and ZIP file
    Write-Host "Cleaning up temporary files..."
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
