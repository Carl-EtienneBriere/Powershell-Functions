Function Search-Item
{
    <#
    .SYNOPSIS
        Searches for text in files, filenames, or directory names.

    .FUNCTIONALITY
        This function performs a recursive search within a specified path to find either text inside files, 
        specific filenames, or directory names matching a given keyword.

    .DESCRIPTION
        The `Search-Item` function allows you to search within a directory structure for:
        - Text inside files
        - Files with names matching the keyword
        - Directories with names matching the keyword
        
        It provides progress feedback during execution and returns the results as a collection of `PSCustomObject` 
        with a single column: `Path`. The function supports filtering files by extensions when searching for text or filenames.

    .PARAMETER Type
        Specifies the type of search to perform. Valid values:
        - "Text"       : Searches for a keyword inside files.
        - "File"       : Searches for files with names containing the keyword.
        - "Directory"  : Searches for directories with names containing the keyword.

    .PARAMETER Path
        The root directory where the search will be performed. Must be a valid path.

    .PARAMETER Keyword
        The keyword to search for in filenames, directory names, or file content (when Type is "Text").

    .PARAMETER Extensions
        An optional array of file extensions to filter the search when Type is "Text" or "File". 
        If not specified, all file types are searched.

    .EXAMPLE
        # Search for all PowerShell scripts containing "Import-Module" inside them
        Search-Item -Type "Text" -Path "C:\Scripts" -Keyword "Import-Module" -Extensions @(".ps1")

    .EXAMPLE
        # Find all files with "Report" in their name inside a specific folder
        Search-Item -Type "File" -Path "D:\Projects" -Keyword "Report"

    .EXAMPLE
        # Search for directories containing "Backup" in their names
        Search-Item -Type "Directory" -Path "E:\Archives" -Keyword "Backup"

    .EXAMPLE
        # Find all `.log` files that contain the text "Error"
        Search-Item -Type "Text" -Path "C:\Logs" -Keyword "Error" -Extensions @(".log")

    .LINK
        Créé par / Created by : Carl-Étienne Brière
        Date de création / Creation date : 2025-02-07
    #>

    [CmdletBinding()]
    [Alias("SIT")]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateSet("Text", "File", "Directory")]
        [String]$Type,

        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String[]]$Keywords,

        [String[]]$Extensions
    )

    Begin
    {
        If (-Not (Test-Path -Path $Path))
        {
            Write-Host "The specified path does not exist." -ForegroundColor Red
            Return @()
        }

        $Results = @()
        $AnimationChars = @('|', '/', '–', '\')
        $AnimationIndex = 0
        $ChangeAfter = 10
        $ItemCounter = 0
    }

    Process
    {
        Switch ($Type)
        {
            "Text"
            {
                $Items = Get-ChildItem -Path $Path -Recurse -File
                If ($Extensions) { $Items = $Items | Where-Object { $_.Extension -in $Extensions } }

                $Total = $Items.Count
                $Current = 0

                If ($Total -eq 0)
                {
                    Return @()
                }

                Foreach ($Item In $Items)
                {
                    $Current++
                    $Percent = ($Current / $Total) * 100
                    $ItemCounter++

                    If ($ItemCounter -ge $ChangeAfter)
                    {
                        $ItemCounter = 0
                        $AnimationIndex = ($AnimationIndex + 1) % $AnimationChars.Length
                    }

                    Write-Progress -Activity "Searching for text in files... $($AnimationChars[$AnimationIndex])" -Status "Processing $Current of $Total" -PercentComplete $Percent

                    Foreach ($Keyword in $Keywords)
                    {
                        If (Select-String -Path $Item.FullName -Pattern $Keyword -Quiet)
                        {
                            $Results += [PSCustomObject]@{ Path = $Item.FullName; Value = $Keyword }
                        }
                    }
                }
            }

            "File"
            {
                $Items = Get-ChildItem -Path $Path -Recurse -File
                If ($Extensions) { $Items = $Items | Where-Object { $_.Extension -in $Extensions } }

                $Total = $Items.Count
                $Current = 0

                If ($Total -eq 0)
                {
                    Return @()
                }

                Foreach ($Item In $Items)
                {
                    $Current++
                    $Percent = ($Current / $Total) * 100
                    $ItemCounter++

                    If ($ItemCounter -ge $ChangeAfter)
                    {
                        $ItemCounter = 0
                        $AnimationIndex = ($AnimationIndex + 1) % $AnimationChars.Length
                    }

                    Write-Progress -Activity "Searching for files... $($AnimationChars[$AnimationIndex])" -Status "Processing $Current of $Total" -PercentComplete $Percent

                    Foreach ($Keyword in $Keywords)
                    {
                        If ($Item.Name -Like "*$Keyword*")
                        {
                            $Results += [PSCustomObject]@{ Path = $Item.FullName; Value = $Keyword }
                        }
                    }
                }
            }

            "Directory"
            {
                $Items = Get-ChildItem -Path $Path -Recurse -Directory
                $Total = $Items.Count
                $Current = 0

                If ($Total -eq 0)
                {
                    Return @()
                }

                Foreach ($Item In $Items)
                {
                    $Current++
                    $Percent = ($Current / $Total) * 100
                    $ItemCounter++

                    If ($ItemCounter -ge $ChangeAfter)
                    {
                        $ItemCounter = 0
                        $AnimationIndex = ($AnimationIndex + 1) % $AnimationChars.Length
                    }

                    Write-Progress -Activity "Searching for directories... $($AnimationChars[$AnimationIndex])" -Status "Processing $Current of $Total" -PercentComplete $Percent

                    Foreach ($Keyword in $Keywords)
                    {
                        If ($Item.Name -Like "*$Keyword*")
                        {
                            $Results += [PSCustomObject]@{ Path = $Item.FullName; Value = $Keyword }
                        }
                    }
                }
            }
        }
    }

    End
    {
        Write-Progress -Activity "Search completed" -Completed
        Return $Results
    }
}
