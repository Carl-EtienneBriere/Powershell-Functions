Function Get-InstalledSoftware
{
    <#
    .SYNOPSIS
        Retrieves a list of installed software on the system.
    
    .DESCRIPTION
        This function fetches installed software from both 64-bit and 32-bit 
        registry paths (on 64-bit systems). It returns application name, 
        version, product code, and uninstall string.
    
    .OUTPUTS
        PSCustomObject: Contains Application, Version, ProductCode, and UninstallString.
    
    .NOTES
        Created by : Carl-Étienne Brière
    #>
    # Define registry paths for installed software (64-bit and 32-bit on 64-bit systems)
    $UninstallKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $SoftwareList = @()

    # Retrieve installed software from registry
    Foreach ($KeyPath in $UninstallKeys)
    {
        Get-ItemProperty -Path $KeyPath | ForEach-Object {
            If ($_.PSChildName -match "^{")  # Ensure it has a ProductCode (GUID-based entries)
            {
                $SoftwareList += [PSCustomObject]@{
                    Application     = $_.DisplayName
                    Version         = $_.DisplayVersion
                    ProductCode     = $_.PSChildName
                    UninstallString = $_.UninstallString
                }
            }
        }
    }

    # Return sorted output excluding unnecessary properties
    Return $SoftwareList | Select-Object * -ExcludeProperty PSComputerName, RunspaceID | Sort-Object Application
}
