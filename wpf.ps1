# 1. Load the required WPF assembly
Add-Type -AssemblyName PresentationFramework

# 2. Define the entire UI as a XAML text block
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="My First WPF App" Height="200" Width="350"
        WindowStartupLocation="CenterScreen">
    <StackPanel Margin="15">
        <Label Name="MyLabel" Content="Hello, World!" FontSize="16" HorizontalAlignment="Center"/>
        <Button Name="MyButton" Content="Click Me" Width="100" Height="30" Margin="20"/>
    </StackPanel>
</Window>
"@

# 3. Load the XAML into a live window object
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

# 4. Find the controls from the XAML by their 'Name'
$button = $window.FindName("MyButton")
$label = $window.FindName("MyLabel")

# 5. Attach PowerShell logic (an event handler) to the controls
$button.Add_Click({
    $label.Content = "Hello, WPF!"
    $label.Foreground = "Blue"
})

# 6. Show the window
$window.ShowDialog() | Out-Null