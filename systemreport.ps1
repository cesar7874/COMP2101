param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

function Get-SystemReport {
    function Get-SystemHardware {
        # ...
    }

    function Get-OperatingSystem {
        # ...
    }

    function Get-Processor {
        # ...
    }

    function Get-RAM {
        # ...
    }

    function Get-PhysicalDisks {
        # ...
    }

    function Get-VideoCard {
        # ...
    }

    function Get-NetworkAdapter {
        # ...
    }

    if ($System) {
        Write-Host "System Hardware:"
        Get-SystemHardware | Format-List

        Write-Host "Operating System:"
        Get-OperatingSystem | Format-List

        Write-Host "Processor:"
        Get-Processor | Format-List

        Write-Host "RAM:"
        $ramInfo = Get-RAM | Format-Table Manufacturer, PartNumber, Capacity, BankLabel, DeviceLocator -AutoSize
        $totalRAM = [math]::Round((Get-RAM | Measure-Object Capacity -Sum).Sum / 1GB, 2)
        $ramInfo
        Write-Host "Total RAM Installed: $totalRAM GB"

        Write-Host "Video Card:"
        Get-VideoCard | Format-List
    }

    if ($Disks) {
        Write-Host "Physical Disks:"
        Get-PhysicalDisks | Format-Table Manufacturer, Location, Drive, "Size(GB)", "FreeSpace(GB)", PercentFree -AutoSize
    }

    if ($Network) {
        Write-Host "Network Adapter Configuration:"
        Get-NetworkAdapter | Format-Table AdapterDescription, AdapterIndex, IPAddress, SubnetMask, DNSDomain, DNSServer -AutoSize
    }
}

# Generate the report based on specified parameters
Get-SystemReport
