function Get-SystemHardware {
    Get-CimInstance -ClassName Win32_ComputerSystem
}

function Get-OperatingSystem {
    Get-CimInstance -ClassName Win32_OperatingSystem
}

function Get-Processor {
    Get-CimInstance -ClassName Win32_Processor
}

function Get-RAM {
    Get-CimInstance -ClassName Win32_PhysicalMemory
}

function Get-PhysicalDisks {
    $diskdrives = Get-CimInstance CIM_DiskDrive
    $diskInfo = @()

    foreach ($disk in $diskdrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_DiskPartition

        foreach ($partition in $partitions) {
            $logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk

            foreach ($logicaldisk in $logicaldisks) {
                $diskInfo += [PSCustomObject]@{
                    Manufacturer = $disk.Manufacturer
                    Location = $partition.DeviceID
                    Drive = $logicaldisk.DeviceID
                    "Size(GB)" = [math]::Round($logicaldisk.Size / 1GB, 2)
                    "FreeSpace(GB)" = [math]::Round($logicaldisk.FreeSpace / 1GB, 2)
                    "PercentFree" = [math]::Round(($logicaldisk.FreeSpace / $logicaldisk.Size) * 100, 2)
                }
            }
        }
    }

    $diskInfo
}

function Get-VideoCard {
    Get-CimInstance -ClassName Win32_VideoController
}

function Get-NetworkAdapter {
    $networkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
    
    $report = $networkAdapters | ForEach-Object {
        [PSCustomObject]@{
            AdapterDescription = $_.Description
            AdapterIndex = $_.Index
            IPAddress = $_.IPAddress -join ', ' -replace '0.0.0.0, ', ''
            SubnetMask = $_.IPSubnet -join ', ' -replace '0.0.0.0, ', ''
            DNSDomain = $_.DNSDomain
            DNSServer = $_.DNSServerSearchOrder -join ', ' -replace '0.0.0.0, ', ''
        }
    }

    $report
}

# Display system information
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

Write-Host "Physical Disks:"
Get-PhysicalDisks | Format-Table Manufacturer, Location, Drive, "Size(GB)", "FreeSpace(GB)", PercentFree -AutoSize

Write-Host "Network Adapter Configuration:"
Get-NetworkAdapter | Format-Table AdapterDescription, AdapterIndex, IPAddress, SubnetMask, DNSDomain, DNSServer -AutoSize

Write-Host "Video Card:"
Get-VideoCard | Format-List