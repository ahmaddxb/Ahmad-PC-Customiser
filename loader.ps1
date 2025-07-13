<#
.SYNOPSIS
    This loader script downloads the pre-built, single-file version of the 
    "Ahmaddxb Windows Customiser" from GitHub and executes it directly.
#>

# --- CONFIGURATION ---
# Make sure these match your GitHub username, repository name, and branch.
$githubUser = "ahmaddxb"
$repoName   = "Ahmad-PC-Customiser"
$branchName = "main" # IMPORTANT: Change this to "main" if that is your repository's default branch.
# --- END CONFIGURATION ---

# Construct the direct URL to the raw, pre-built script file
$scriptUrl = "https://raw.githubusercontent.com/$githubUser/$repoName/refs/heads/$branchName/dist/Ahmaddxb-Customiser-SingleFile.ps1"
https://raw.githubusercontent.com/ahmaddxb/Ahmad-PC-Customiser/refs/heads/main/loader.ps1
Write-Host "Downloading and executing the customiser v2 from:"
Write-Host $scriptUrl -ForegroundColor Cyan

try {
    # Download the script content into memory and execute it
    Invoke-Expression (Invoke-RestMethod -Uri $scriptUrl)
}
catch {
    Write-Error "Failed to download or execute the script. Please check the URL and your internet connection."
    Write-Error "Error details: $($_.Exception.Message)"
}
