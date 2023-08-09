# Get network adapter configuration objects for enabled adapters
$networkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

# Create a custom object with the desired information
$report = $networkAdapters | ForEach-Object {
    [PSCustomObject]@{
        AdapterDescription = $_.Description
        AdapterIndex       = $_.Index
        IPAddress         = $_.IPAddress -join ', '
        SubnetMask        = $_.IPSubnet -join ', '
        DNSDomain         = $_.DNSDomain
        DNSServer         = $_.DNSServerSearchOrder -join ', '
    }
}

# Format and display the report
$report | Format-Table -AutoSize -Property AdapterDescription, AdapterIndex, IPAddress, SubnetMask, DNSDomain, DNSServer