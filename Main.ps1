#----------------------------------
#  SCRIPT CONFIGURATION
#----------------------------------
#requires -version 5.1
#requires -runasadministrator

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    break
}

Add-Type -AssemblyName System.Windows.Forms

# --- Define Base Paths ---
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config"
$FunctionsPath = Join-Path -Path $PSScriptRoot -ChildPath "functions"
$TabsPath = Join-Path -Path $PSScriptRoot -ChildPath "tabs"

# --- Dot-Source All Components ---
. (Join-Path -Path $ConfigPath -ChildPath "RemoveApps.config.ps1")
. (Join-Path -Path $ConfigPath -ChildPath "WindowsTweaks.config.ps1")
. (Join-Path -Path $ConfigPath -ChildPath "InstallApps.config.ps1")

. (Join-Path -Path $FunctionsPath -ChildPath "App-Removal.functions.ps1")
. (Join-Path -Path $FunctionsPath -ChildPath "Tweak-Checks.functions.ps1")
. (Join-Path -Path $FunctionsPath -ChildPath "Backup.functions.ps1")
. (Join-Path -Path $FunctionsPath -ChildPath "App-Install.functions.ps1")

# --- Create the Main Form and Controls ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ahmaddxb Windows Customiser"
$form.Size = New-Object System.Drawing.Size(480, 680)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Sizable"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# --- CORRECTED: The TabControl is now the main control and docks to fill the form ---
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($tabControl)

# --- Dot-Source the UI for Each Tab ---
# The scripts will now add their tab pages to the main $tabControl
. (Join-Path -Path $TabsPath -ChildPath "Tab.RemoveApps.ps1")
. (Join-Path -Path $TabsPath -ChildPath "Tab.WindowsTweaks.ps1")
. (Join-Path -Path $TabsPath -ChildPath "Tab.InstallApps.ps1")
. (Join-Path -Path $TabsPath -ChildPath "Tab.Backup.ps1")
# If you still have Tab.JobTest.ps1, you can remove the line that loads it.

# --- Show the Form ---
$form.ShowDialog()