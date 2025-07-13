function RefreshCheckboxesRemoveApp {
    foreach ($checkboxInfo in $checkboxes) {
        $packageName = $checkboxInfo.Name
        $checkbox = $checkboxInfo.Checkbox
        $package = Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $packageName
        $checkbox.Checked = ($null -ne $package)
    }
}