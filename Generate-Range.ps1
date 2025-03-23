Function Generate-Range
{
<#
.SYNOPSIS
    This function generates a list of numbered patterns based on a given pattern.

.DESCRIPTION
    - This function takes a string pattern, a starting number, and an ending number to generate a list of numbered patterns.
    - The generated patterns follow the provided format and are numbered sequentially, with leading zeros added to ensure uniform length.
    
.INPUTS
    - $Pattern (String) : The pattern used for generating the numbered strings. For example, "Item-" to generate "Item-001", "Item-002", etc.
    - $From (String) : The starting number of the sequence.
    - $To (String) : The ending number of the sequence.
    
.EXAMPLE
    $GeneratedList = Generate-Range -Pattern "Item-" -From 1 -To 10
    This command generates a list of numbered patterns from "Item-001" to "Item-010".
    
.NOTES
    Created by: Carl-Étienne Brière
#> 
    Param
    (
        [String]$Pattern,
        [String]$From,
        [String]$To
    )

    Switch($From.Length)
    {
        1 { $ZeroPadding = "0" }
        2 { $ZeroPadding = "00" }
        3 { $ZeroPadding = "000" }
        Default { $ZeroPadding = "000" }
    }

    $NumberedPatterns = $From..$To | ForEach-Object { $Pattern + $_.ToString($ZeroPadding) }

    Return $NumberedPatterns
}
