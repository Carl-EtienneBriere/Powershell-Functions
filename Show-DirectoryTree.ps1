Function Show-DirectoryTree
{
    <#
    .SYNOPSIS
        This function generates a directory tree view of a specified folder, displaying all subdirectories and files.

    .DESCRIPTION
        - This function takes a folder path and creates a graphical interface displaying its directory structure.
        - The user can expand or collapse the directories and open the selected item.
        - The user can toggle between light and dark themes for the UI.
    
    .INPUTS
        - $FolderPath (String) : The path to the folder whose directory tree will be displayed.
        - $Font (String) : The font used for displaying the tree. Default is "Segoe UI".
        - $FontSize (Int) : The font size for the tree. Default is 12.

    .EXAMPLE
        Show-DirectoryTree -FolderPath "C:\Users\Public"
        This command generates a tree view of the "C:\Users\Public" directory.
    
    .NOTES
        Created by: Carl-Étienne Brière
    #>
    [CmdletBinding()]
    [Alias("SDT")]
    Param
    (
        [String]$FolderPath,
        [String]$Font = "Segoe UI",  # Default font
        [Int]$FontSize = 12          # Default font size
    )

    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    # Check if the folder exists
    If (-Not (Test-Path $FolderPath))
    {
        [System.Windows.Forms.MessageBox]::Show("The specified folder does not exist...", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Return
    }

    # Create a form window
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Directory Tree of $FolderPath"
    $Form.Size = New-Object System.Drawing.Size(1280, 800)  # Larger initial size
    $Form.StartPosition = "CenterScreen"  # Center the window on the screen

    # Create a TreeView to display the directory tree
    $TreeView = New-Object System.Windows.Forms.TreeView
    $TreeView.Dock = [System.Windows.Forms.DockStyle]::Fill  # Fill the available space
    $TreeView.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $TreeView.Font = New-Object System.Drawing.Font($Font, $FontSize)  # Apply the specified font and size
    
    # Function to recursively add directories and files to the TreeView
    Function Add-TreeNode
    {
        Param
        (
            [String]$Path,
            [System.Windows.Forms.TreeNode]$ParentNode
        )

        # Add a node with the name of the folder or file
        $Node = New-Object System.Windows.Forms.TreeNode (Split-Path $Path -Leaf)

        # If it's a folder, set it to bold
        If (Test-Path $Path)
        {
            $Item = Get-Item $Path
            If ($Item.PSIsContainer)
            {
                # Folder - bold font
                $Node.NodeFont = New-Object System.Drawing.Font($TreeView.Font.FontFamily, $TreeView.Font.Size, [System.Drawing.FontStyle]::Bold)
            }
            Else
            {
                # File - normal font
                $Node.NodeFont = $TreeView.Font
            }
        }

        $ParentNode.Nodes.Add($Node)

        # If it's a folder, explore its contents
        If (Test-Path $Path)
        {
            $Item = Get-Item $Path
            If ($Item.PSIsContainer)
            {
                $SubDirs = Get-ChildItem -Path $Path -Directory
                Foreach ($subDir in $SubDirs)
                {
                    Add-TreeNode -path $subDir.FullName -parentNode $Node
                }
                
                $SubFiles = Get-ChildItem -Path $Path -File
                Foreach ($File in $SubFiles)
                {
                    $FileNode = New-Object System.Windows.Forms.TreeNode ($File.Name)
                    # Apply standard font to files
                    $FileNode.NodeFont = $TreeView.Font
                    $Node.Nodes.Add($FileNode) | Out-Null
                }
            }
        }
    }

    Function Set-Theme
    {
        Param
        (
            [System.Windows.Forms.Form]$Form,
            [System.Windows.Forms.TreeView]$TreeView,
            [System.Windows.Forms.Button]$ExpandAllButton,
            [System.Windows.Forms.Button]$OpenLocationButton,
            [System.Windows.Forms.CheckBox]$DarkModeCheckbox,
            [Boolean]$DarkMode
        )

        If ($DarkMode)
        {
            # Apply dark theme
            $Form.BackColor               = [System.Drawing.Color]::FromArgb(45, 45, 48)
            $TreeView.BackColor           = [System.Drawing.Color]::FromArgb(28, 28, 28)
            $TreeView.ForeColor           = [System.Drawing.Color]::White
            $ExpandAllButton.BackColor    = [System.Drawing.Color]::FromArgb(28, 28, 28)
            $ExpandAllButton.ForeColor    = [System.Drawing.Color]::White
            $OpenLocationButton.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 28)
            $OpenLocationButton.ForeColor = [System.Drawing.Color]::White
            $DarkModeCheckbox.BackColor   = [System.Drawing.Color]::FromArgb(45, 45, 48)
            $DarkModeCheckbox.ForeColor   = [System.Drawing.Color]::White
        }
        Else
        {
            # Apply light theme
            $Form.BackColor               = [System.Drawing.Color]::White
            $TreeView.BackColor           = [System.Drawing.Color]::White
            $TreeView.ForeColor           = [System.Drawing.Color]::Black
            $ExpandAllButton.BackColor    = [System.Drawing.Color]::FromArgb(240, 240, 240)
            $ExpandAllButton.ForeColor    = [System.Drawing.Color]::Black
            $OpenLocationButton.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
            $OpenLocationButton.ForeColor = [System.Drawing.Color]::Black
            $DarkModeCheckbox.BackColor   = [System.Drawing.Color]::White
            $DarkModeCheckbox.ForeColor   = [System.Drawing.Color]::Black
        }
    }

    # Create the root node for the specified folder (use only the folder name)
    $RootNode = New-Object System.Windows.Forms.TreeNode (Split-Path $FolderPath -Leaf)

    # Add the root node (folder name)
    If ($TreeView.Nodes.Count -eq 0)
    {
        $TreeView.Nodes.Add($RootNode) | Out-Null
    }

    # Add the directory structure (without duplicating the root folder)
    $SubDirs = Get-ChildItem -Path $FolderPath -Directory
    Foreach ($subDir in $SubDirs)
    {
        Add-TreeNode -path $subDir.FullName -parentNode $RootNode | Out-Null
    }

    $SubFiles = Get-ChildItem -Path $FolderPath -File
    Foreach ($File in $SubFiles)
    {
        $FileNode = New-Object System.Windows.Forms.TreeNode ($File.Name)
        $FileNode.NodeFont = $TreeView.Font
        $RootNode.Nodes.Add($FileNode) | Out-Null
    }
    
    # Function to adjust the width of the nodes
    Function Adjust-TreeViewWidth
    {
        $TreeView.Width = 0
        Foreach ($Node in $TreeView.Nodes)
        {
            $Node.Expand()
            Foreach ($SubNode in $Node.Nodes)
            {
                $SubNode.Expand()
            }
        }
    }
    
    # Add the TreeView to the form
    $Form.Controls.Add($TreeView)

    # Create a panel for buttons at the bottom of the window
    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $Panel.Height = 50
    $Panel.Padding = New-Object System.Windows.Forms.Padding(10)

    # Create an "Expand All" button
    $ExpandAllButton = New-Object System.Windows.Forms.Button
    $ExpandAllButton.Text = "Expand All"
    $ExpandAllButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $ExpandAllButton.Size = New-Object System.Drawing.Size(100, 30)
    $ExpandAllButton.Location = New-Object System.Drawing.Point(10, 10)
    $ExpandAllButton.Add_Click({
        $TreeView.ExpandAll()
        Adjust-TreeViewWidth
    })

    # Create an "Open Location" button
    $OpenLocationButton = New-Object System.Windows.Forms.Button
    $OpenLocationButton.Text = "Open Item"
    $OpenLocationButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $OpenLocationButton.Size = New-Object System.Drawing.Size(150, 30)
    $OpenLocationButton.Location = New-Object System.Drawing.Point(120, 10)
    $OpenLocationButton.Add_Click({
        $SelectedNode = $TreeView.SelectedNode
        If ($SelectedNode)
        {
            $FullPath = $SelectedNode.FullPath
            $FullPath = Join-Path -Path $(Split-Path -Path $FolderPath -Parent) -ChildPath $FullPath
        
            # Open if the path exists
            If (Test-Path $FullPath) {
                Invoke-Item $FullPath
            }
            Else {
                [System.Windows.Forms.MessageBox]::Show("The selected path does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })
    
    $Panel.Controls.Add($ExpandAllButton)
    $Panel.Controls.Add($OpenLocationButton)

    # Add the panel to the form
    $Form.Controls.Add($Panel)

    # Create the dark mode toggle
    $DarkModeCheckbox = New-Object System.Windows.Forms.CheckBox
    $DarkModeCheckbox.Text = "Enable Dark Mode"
    $DarkModeCheckbox.Checked = $false  # Default is Light Mode
    $DarkModeCheckbox.Location = New-Object System.Drawing.Point(280, 10)
    $DarkModeCheckbox.Size = New-Object System.Drawing.Size(150, 30)
    $DarkModeCheckbox.Add_CheckedChanged({
        If ($DarkModeCheckbox.Checked)
        {
            Set-Theme -Form $Form -TreeView $TreeView -ExpandAllButton $ExpandAllButton -OpenLocationButton $OpenLocationButton -DarkModeCheckbox $DarkModeCheckbox -DarkMode $true
        }
        Else
        {
            Set-Theme -Form $Form -TreeView $TreeView -ExpandAllButton $ExpandAllButton -OpenLocationButton $OpenLocationButton -DarkModeCheckbox $DarkModeCheckbox -DarkMode $false
        }
    })
    $Panel.Controls.Add($DarkModeCheckbox)

    Set-Theme -Form $Form -TreeView $TreeView -ExpandAllButton $ExpandAllButton -OpenLocationButton $OpenLocationButton -DarkModeCheckbox $DarkModeCheckbox -DarkMode $true

    # Show the form
    $Form.ShowDialog()
}
