function IsTweakApplied($tweakName) {
    switch ($tweakName) {
        "Enable Dark Mode" {
            $appsUseLightTheme = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
            $systemUsesLightTheme = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -ErrorAction SilentlyContinue
            return ($appsUseLightTheme -eq 0) -and ($systemUsesLightTheme -eq 0)
        }
        "Open File Explorer to This PC" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "File Explorer Show File Extentions" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "File Explorer show hidden files" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Hide Widget on Task Bar" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "Set desktop icon size to small" {
            $iconSizeValue = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "IconSize" -ErrorAction SilentlyContinue
            return ($iconSizeValue -eq 32)
        }
        "windows 11 task bar to hide search" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "Hide Chat on Task Bar" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        "disable search web results on Windows 11" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Show This PC on desktop" {
            $registryValue = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
            return ($null -ne $registryValue -and $registryValue -eq 0)
        }
        # "Turn on Use Print Screen Key to Open Screen Snipping" {
        #     $registryValue = Get-ItemPropertyValue -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -ErrorAction SilentlyContinue
        #     return ($registryValue -eq 1)
        # }
        "Turn On Set Time Zone Automatically" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -ErrorAction SilentlyContinue
            return ($registryValue -eq 3)
        }
        "Change Time Format" {
            $sShortTime = Get-ItemPropertyValue -Path "HKCU:\Control Panel\International" -Name "sShortTime" -ErrorAction SilentlyContinue
            $sTimeFormat = Get-ItemPropertyValue -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -ErrorAction SilentlyContinue
            return ($sShortTime -eq "h:mm tt") -and ($sTimeFormat -eq "h:mm:ss tt")
        }
        "Turn off Automatic Proxy Configuration" {
            $ProxyEnable = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -ErrorAction SilentlyContinue
            return ($ProxyEnable -eq 0)
        }
        "Change UAC Behavior for Administrators to Elevate without prompting" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue
            return ($registryValue -eq 0)
        }
        # "Turn On Receive Updates for Other Microsoft Products" {
        #     $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "AllowMUUpdateService" -ErrorAction SilentlyContinue
        #     return ($registryValue -eq 1)
        # }
        "Turn On Get me up to date for Windows Update" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsExpedited" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Turn On Auto-restart Notifications for Windows Update in Settings" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        "Get Latest Updates as soon as available in Windows 11" {
            $registryValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsContinuousInnovationOptedIn" -ErrorAction SilentlyContinue
            return ($registryValue -eq 1)
        }
        default {
            return $false
        }
    }
}

function RefreshCheckboxesTweaks {
    foreach ($checkbox in $checkboxesWindowsTweaks) {
        $tweakName = $checkbox.Text
        $checkbox.Checked = IsTweakApplied($tweakName)
    }
}