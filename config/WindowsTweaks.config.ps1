$windowsTweaksMapping = @{
    "Enable Dark Mode"                                                    = {
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force
    }
    "Open File Explorer to This PC"                                       = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 }
    "File Explorer Show File Extentions"                                  = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 }
    "File Explorer show hidden files"                                     = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 }
    "Hide Widget on Task Bar"                                             = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 1 }
    "Set desktop icon size to small"                                      = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "IconSize" -Value 32 -Force
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "Mode" -Value 1 -Force
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "LogicalViewMode" -Value 3 -Force
    }
    "windows 11 task bar to hide search"                                  = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force }
    "Hide Chat on Task Bar"                                               = { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Force }
    "disable search web results on Windows 11"                            = {
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name DisableSearchBoxSuggestions -Value 1 -PropertyType DWORD -Force
    }
    "Show This PC on desktop"                                             = { New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Force }
    "Turn on Use Print Screen Key to Open Screen Snipping"                = { New-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 1 -Force }
    "Turn On Set Time Zone Automatically"                                 = {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3 -Force
        Set-TimeZone -Name "Arabian Standard Time"
        Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c w32tm /resync"
    }
    "Change Time Format"                                                  = {
        New-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "h:mm tt" -Force
        New-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "h:mm:ss tt" -Force
    }
    "Turn off Automatic Proxy Configuration"                              = {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "AutoDetect" -Value 0
    }
    "Change UAC Behavior for Administrators to Elevate without prompting" = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0" -Force }
    "Turn On Receive Updates for Other Microsoft Products"                = {
        (New-Object -com "Microsoft.Update.ServiceManager").AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "AllowMUUpdateService" -Value "1" -Force
    }
    "Turn On Get me up to date for Windows Update"                        = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsExpedited" -Value "1" -Force }
    "Turn On Auto-restart Notifications for Windows Update in Settings"   = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Value "1" -Force }
    "Get Latest Updates as soon as available in Windows 11"               = { New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsContinuousInnovationOptedIn" -Value "1" -Force }
}