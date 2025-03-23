Function Test-ConnectionTimeout
{
    <#
    .SYNOPSIS
        This function checks the connectivity to a specified computer or IP address within a given timeout period.

    .DESCRIPTION
        - This function attempts to ping a specified computer or IP address and returns whether the connection is successful.
        - It verifies that the input is a valid computer name or IP address before initiating the connection test.
        - The function waits for a response within the specified timeout period before returning the result.
    
    .INPUTS
        - $Target (String) : The computer name or IP address to check connectivity for. Defaults to the local machine.
        - $TimeoutInMilliseconds (Int) : The maximum time to wait for a response. Default is 500ms.

    .EXAMPLE
        Test-ConnectionTimeout -Target "Server01" -TimeoutInMilliseconds 300
        This command checks the connectivity to "Server01" within a 300ms timeout.
    
    .EXAMPLE
        Test-ConnectionTimeout -Target "192.168.1.1" -TimeoutInMilliseconds 300
        This command checks the connectivity to the IP address "192.168.1.1" within a 300ms timeout.
    
    .NOTES
        Created by: Carl-Étienne Brière
    #>
    Param
    (
        [String]$Target = $ENV:COMPUTERNAME,
        [Int]$TimeoutInMilliseconds = 500
    )

    # Check if the target is a valid IP address
    $IsValidIP = $Target -match "^(\d{1,3}\.){3}\d{1,3}$" -and ($Target -split '\.') -as [int] -notcontains {$_ -gt 255}

    # Check if the target is a valid computer name
    $IsValidComputerName = $Target -match '^[a-zA-Z0-9\-]+$'

    If (-not ($IsValidIP -or $IsValidComputerName))
    {
        Return $False
    }

    # Perform a ping test to check connectivity
    $PingTask = Test-Connection -ComputerName $Target -Count 1 -AsJob
    $StartTime = Get-Date

    # Wait for a response within the specified timeout period
    While ((Get-Date) -lt $StartTime.AddMilliseconds($TimeoutInMilliseconds))
    {
        If ($PingTask.State -eq 'Completed')
        {
            # Retrieve the ping result
            $PingResult = Receive-Job -Job $PingTask -Wait -AutoRemoveJob
            If ($PingResult.StatusCode -eq 0)  # Status 0 means success
            {
                Return $True
            }
            Else
            {
                Return $False
            }
        }
    }
    Return $False
}
