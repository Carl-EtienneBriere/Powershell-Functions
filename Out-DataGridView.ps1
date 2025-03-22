Function Out-DataGridView
{
    <#
    .SYNOPSIS
        Displays data in a Windows Forms DataGridView.
    
    .FUNCTIONALITY
        This function takes data and displays it in a DataGridView in a Windows Forms window.
        It allows customization of window title, font, border style, and more.
    
    .DESCRIPTION
        The `Out-DataGridView` function takes input data and displays it in a DataGridView control within a Windows Forms window. 
        You can customize various window properties such as title, icon, size, and appearance of the DataGridView.
        The data is dynamically bound to the DataGridView, and various styles can be applied, including alternating row colors.
        The function supports user interaction with features like column resizing and row selection.
    
    .PARAMETER Data
        The data to display in the DataGridView. This can be passed via pipeline.
    
    .PARAMETER WindowTitle
        The title of the window. Default is "Out-DataGridView".
    
    .PARAMETER WindowIconPath
        The path to the icon to display in the window. Default is `$null`.
    
    .PARAMETER WindowWidth
        The width of the window. Default is 1300.
    
    .PARAMETER WindowHeight
        The height of the window. Default is 730.
    
    .PARAMETER Font
        The font for the DataGridView. Default is "Arial".
    
    .PARAMETER FontSize
        The font size for the DataGridView text. Default is 12.
    
    .PARAMETER AlternateRowHexColor
        The background color for alternating rows in hexadecimal format. Default is "#F2F2F2".
    
    .PARAMETER FilterPanelWidth
        The width of the filter panel on the left side of the DataGridView. Default is 200.
    
    .PARAMETER BorderSize
        The size of the border around the DataGridView. Default is 20.
    
    .PARAMETER BorderStyle
        The border style of the window. Default is "Sizable".
        Options include: Fixed3d, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow.
    
    .EXAMPLE
        # Display a list of processes in a DataGridView
        Get-Process | Select-Object Name, Id, CPU | Out-DataGridView
    
    .EXAMPLE
        # Display files in a folder with custom window title and icon
        Get-ChildItem -Path "C:\Users" | Out-DataGridView -WindowTitle "User Files" -WindowIconPath "C:\path\to\icon.ico"
    
    .EXAMPLE
        # Display the output of Get-Service in a DataGridView
        Get-Service | Out-DataGridView -WindowTitle "Services in System" -Font "Calibri" -FontSize 14
    
    .LINK
        Créé par : Carl-Étienne Brière
        Date de création : 2025-01-31
    
        Created by : Carl-Étienne Brière
        Creation date : 2025-01-31
    #>

    [Alias("ODGV")]
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        $Data,

        [String]$WindowTitle = "Out-DataGridView",
        [ValidateSet("Information","Question","Exclamation","Error","Shield")]
        [String]$WindowIcon = "Shield",
        [String]$WindowIconPath = $null,
        [Int]$WindowWidth = 1300,
        [Int]$WindowHeight = 730,

        [ValidateSet("Arial","Calibri","Cambria","Comic Sans MS","Consolas","Courier New","Georgia","Segoe UI","Tahoma","Times New Roman","Verdana","Calibri","Georgia")]
        [String]$Font = "Arial",
        [Int]$FontSize = 12,

        [ValidatePattern("^#([A-Fa-f0-9]{6})$")] 
        [String]$AlternateRowHexColor = "#F2F2F2",

        [ValidateRange(200,500)]
        [Int]$FilterPanelWidth = 200,

        [Int]$BorderSize = 20,
        [ValidateSet("Fixed3d","FixedDialog","FixedSingle","FixedToolWindow","None","Sizable","SizableToolWindow")]
        $BorderStyle = "Sizable"
    )

    Begin
    {
        Add-Type -AssemblyName PresentationCore
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        [System.Windows.Forms.Application]::EnableVisualStyles()

        $global:AllData = New-Object System.Collections.ArrayList  
    }

    Process
    {
        [Void]$global:AllData.Add($Data)  
    }

    End
    {
        If ($global:AllData.Count -gt 0)
        {
            Add-Type -AssemblyName PresentationCore
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            [System.Windows.Forms.Application]::EnableVisualStyles()

            $Form = New-Object System.Windows.Forms.Form
            $Form.Text = $WindowTitle
            $Form.Size = New-Object System.Drawing.Size($WindowWidth, $WindowHeight)
            $Form.StartPosition = "CenterScreen"
            $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::$BorderStyle
            $Form.MaximizeBox = $True

            If ($WindowIconPath -notlike $null)
            {
                $Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($WindowIconPath)
            }
            Else
            {
                $Form.Icon = [System.Drawing.SystemIcons]::$WindowIcon
            }

            $DataGridView = New-Object System.Windows.Forms.DataGridView
            $DataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::AllCells
            $DataGridView.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize
            $DataGridView.ReadOnly = $True
            $DataGridView.Font = New-Object System.Drawing.Font($Font, $FontSize)
            $DataGridView.Location = New-Object System.Drawing.Point(($BorderSize + $FilterPanelWidth), $BorderSize)
            $DataGridView.Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - (2 * $BorderSize + $FilterPanelWidth))), ($Form.ClientSize.Height - (2 * $BorderSize))
            $DataGridView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor ` 
                                   [System.Windows.Forms.AnchorStyles]::Left -bor ` 
                                   [System.Windows.Forms.AnchorStyles]::Right -bor ` 
                                   [System.Windows.Forms.AnchorStyles]::Bottom

            $DataGridView.AllowUserToOrderColumns        = $True
            $DataGridView.AllowUserToResizeColumns       = $True
            $DataGridView.AllowUserToResizeRows          = $True
            $DataGridView.AllowUserToDeleteRows          = $True

            $Form.Controls.Add($DataGridView)

            $AltRowsStyle = New-Object System.Windows.Forms.DataGridViewCellStyle
            $AltRowsStyle.BackColor = [System.Drawing.ColorTranslator]::FromHtml($AlternateRowHexColor)
            $DataGridView.AlternatingRowsDefaultCellStyle = $AltRowsStyle

            $DataGridView.DefaultCellStyle.Font = New-Object System.Drawing.Font($Font, $FontSize)
            $DataGridView.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font($Font, $FontSize, [System.Drawing.FontStyle]::Bold)

            $Columns = $Data.PSObject.Properties.Name

            $DataTable = New-Object System.Data.DataTable

            # Filtrer useless columns
            $Columns = $Columns | Where-Object { $_ -notin @('RowError', 'RowState', 'Table', 'ItemArray', 'HasErrors', 'PSShowComputerName') }

            Foreach ($Column in $Columns)
            {
                $Null = $DataTable.Columns.Add($Column, [string])
            }

            Foreach ($Item in $global:AllData)
            {
                $Row = $DataTable.NewRow()
                Foreach ($Column in $Columns)
                {
                    $Row[$Column] = $Item.$Column
                }
                $DataTable.Rows.Add($Row)
            }

            $DataGridView.DataSource = $DataTable

            Function Get-Selected-Cell-Size
            {
                Param
                (
                    [System.Windows.Forms.DataGridView]$DataGridView
                )

                $SelectedCells = $DataGridView.SelectedCells

                If ($SelectedCells.Count -gt 0)
                {
                    $SelectedRows = $SelectedCells | ForEach-Object { $_.RowIndex } | Sort-Object -Unique
                    $SelectedColumns = $SelectedCells | ForEach-Object { $_.ColumnIndex } | Sort-Object -Unique

                    $Width = $SelectedColumns.Count
                    $Height = $SelectedRows.Count

                    Return $Width, $Height
                }
                Return 0, 0
            }

            Function Update-DataSource
            {
                # Retrieve all rows from the ListView
                $FilterConditions = @()

                Foreach ($Item in $ListView.Items)
                {
                    $ColumnName  = $Item.SubItems[0].Text # Column selected in the first sub-column
                    $Operator    = $Item.SubItems[1].Text # Operator selected in the second sub-column
                    $FilterValue = $Item.SubItems[2].Text # Value selected in the third sub-column

                    # Create an object representing the filter condition for each row
                    $FilterConditions += [PSCustomObject]@{
                        ColumnName  = $ColumnName
                        Operator    = $Operator
                        FilterValue = $FilterValue
                    }
                }

                # Apply the filters from all the extracted conditions in the ListView
                $FilteredData = $global:AllData

                Foreach ($condition in $FilterConditions)
                {
                    Switch ($condition.Operator)
                    {
                        "StartWith" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -like "$($condition.FilterValue)*" }
                            Break
                        }
                        "EndWith" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -like "*$($condition.FilterValue)" }
                            Break
                        }
                        "Contains" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -like "*$($condition.FilterValue)*" }
                            Break
                        }
                        "Like" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -like "$($condition.FilterValue)*" }
                            Break
                        }
                        "eq" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -eq $condition.FilterValue }
                            Break
                        }
                        "ne" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -ne $condition.FilterValue }
                            Break
                        }
                        "gt" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -gt $condition.FilterValue }
                            Break
                        }
                        "ge" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -ge $condition.FilterValue }
                            Break
                        }
                        "lt" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -lt $condition.FilterValue }
                            Break
                        }
                        "le" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -le $condition.FilterValue }
                            Break
                        }
                        "IN" {
                            $FilterValues = $condition.FilterValue.Split(",")
                            $FilteredData = $FilteredData | Where-Object { $FilterValues -contains $_.$($condition.ColumnName) }
                            Break
                        }
                        "IS NULL" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -eq $null }
                            Break
                        }
                        "IS NOT NULL" {
                            $FilteredData = $FilteredData | Where-Object { $_.$($condition.ColumnName) -ne $null }
                            Break
                        }
                        default {
                            Write-Host "Unsupported operator: $($condition.Operator)"
                            Break
                        }
                    }
                }

                # Rebuild the DataTable with filtered data
                $FilteredDataTable = New-Object System.Data.DataTable
                Foreach ($Column in $Columns)
                {
                    $Null = $FilteredDataTable.Columns.Add($Column, [string])
                }

                Foreach ($Item in $FilteredData)
                {
                    $Row = $FilteredDataTable.NewRow()
                    Foreach ($Column in $Columns)
                    {
                        $Row[$Column] = $Item.$Column
                    }
                    $FilteredDataTable.Rows.Add($Row)
                }

                # Update the DataGridView's data source with the filtered data
                $DataGridView.DataSource = $FilteredDataTable
            }


            $DataGridView_CellMouseEnter = {
                $Width, $Height = Get-Selected-Cell-Size -dataGridView $DataGridView
                $RowIndex = $_.RowIndex
                $ColumnIndex = $_.ColumnIndex
                $DataGridView.Rows[$RowIndex].Cells[$ColumnIndex].ToolTipText = "Sélection : ($Width, $Height)"
            }

            $DataGridView.add_SelectionChanged({
                $DataGridView_CellMouseEnter
                $DataGridView.add_CellMouseEnter($DataGridView_CellMouseEnter)
            })

            # Create the ComboBox for column headers
            $HeaderComboBox = New-Object System.Windows.Forms.ComboBox
            $HeaderComboBox.Location = New-Object System.Drawing.Point($BorderSize, $BorderSize) # Position the ComboBox taking the border into account
            $HeaderComboBox.Size = New-Object System.Drawing.Size(($FilterPanelWidth - $BorderSize), 20) # Adjust the size of the ComboBox
            $HeaderComboBox.Font = New-Object System.Drawing.Font($Font, $FontSize)  # Apply the same font and size as in the function

            # Extract the column names from the DataGridView
            $Columns = $DataGridView.Columns | ForEach-Object { $_.HeaderText }

            # Add the column names to the HeaderComboBox
            $HeaderComboBox.Items.AddRange($Columns)

            # Set a default option if necessary
            $HeaderComboBox.SelectedIndex = 0

            # Add the HeaderComboBox to the form
            $Form.Controls.Add($HeaderComboBox)

            # Create the ComboBox for operators (adjusted with the values you want)
            $OperatorComboBox = New-Object System.Windows.Forms.ComboBox
            $OperatorComboBox.Location = New-Object System.Drawing.Point($BorderSize, ($HeaderComboBox.Bottom + $BorderSize)) # Position under the HeaderComboBox
            $OperatorComboBox.Size = New-Object System.Drawing.Size(($FilterPanelWidth - $BorderSize), 20) # Adjust the size of the ComboBox
            $OperatorComboBox.Font = New-Object System.Drawing.Font($Font, $FontSize)  # Apply the same font and size as in the function

            # Add the desired operators to the OperatorComboBox
            $OperatorComboBox.Items.AddRange(@(
                "StartWith", 
                "EndWith", 
                "Contains", 
                "Like", 
                "gt", 
                "ge", 
                "lt", 
                "le", 
                "eq", 
                "ne", 
                "IN", 
                "IS NULL", 
                "IS NOT NULL"
            ))

            # Set a default option if necessary
            $OperatorComboBox.SelectedIndex = 0

            # Add the OperatorComboBox to the form
            $Form.Controls.Add($OperatorComboBox)

            # Create the TextBox
            $TextBox = New-Object System.Windows.Forms.TextBox
            $TextBox.Location = New-Object System.Drawing.Point(($BorderSize), ($OperatorComboBox.Bottom + $BorderSize)) # Position under the ComboBox
            $TextBox.Size = New-Object System.Drawing.Size(($FilterPanelWidth - $BorderSize), 20) # Adjust the size of the TextBox
            $TextBox.Font = New-Object System.Drawing.Font($Font, $FontSize)  # Apply the same font and size as in the function

            # Add the TextBox to the form
            $Form.Controls.Add($TextBox)

            # Create the "Add" button
            $AddButton = New-Object System.Windows.Forms.Button
            $AddButton.Location = New-Object System.Drawing.Point(($BorderSize), ($TextBox.Bottom + $BorderSize)) # Position under the TextBox
            $AddButton.Size = New-Object System.Drawing.Size(($FilterPanelWidth - $BorderSize), 30) # Adjust the size of the button
            $AddButton.Text = "Add filter" # Set the text of the button
            $AddButton.Font = New-Object System.Drawing.Font($Font, $FontSize)  # Apply the same font and size as in the function

            # Action when clicking "Add"
            $AddButton.Add_Click({
                # Retrieve the selected and entered values
                $SelectedColumn = $HeaderComboBox.SelectedItem
                $selectedOperator = $OperatorComboBox.SelectedItem
                $textValue = $TextBox.Text

                # Create a new item for the ListView
                $listItem = New-Object System.Windows.Forms.ListViewItem($SelectedColumn)

                # Add the operator to the first sub-column
                $listItem.SubItems.Add($selectedOperator)

                # Add the value or NULL if the operator is "IS NOT NULL"
                Switch ($selectedOperator)
                {
                    "IS NOT NULL" {
                        $listItem.SubItems.Add("NULL")
                        Break
                    }
                    "IS NULL" {
                        $listItem.SubItems.Add("NULL")
                        Break
                    }
                    default {
                        $listItem.SubItems.Add($textValue)
                        Break
                    }
                }

                # Add the item to the ListView
                $ListView.Items.Add($listItem)

                # Update the displayed data
                Update-DataSource
            })

            # Add the button to the form
            $Form.Controls.Add($AddButton)

            # Create the ListView
            $ListView = New-Object System.Windows.Forms.ListView
            $ListView.Location = New-Object System.Drawing.Point($BorderSize, ($AddButton.Bottom + $BorderSize)) # Position under the button
            $ListView.Size = New-Object System.Drawing.Size(($FilterPanelWidth - $BorderSize), 200) # Adjust the size of the ListView
            $ListView.View = [System.Windows.Forms.View]::Details # Show details in the ListView
            $ListView.FullRowSelect = $true # Allow full row selection

            # Add columns to the ListView
            $ListView.Columns.Add("Column", [Int]($FilterPanelWidth/3)) | Out-Null
            $ListView.Columns.Add("Operator", [Int]($FilterPanelWidth/3)) | Out-Null
            $ListView.Columns.Add("Value", [Int]($FilterPanelWidth/3)) | Out-Null

            # Add the ListView to the form
            $Form.Controls.Add($ListView)

            # Create the "Remove" button
            $RemoveButton = New-Object System.Windows.Forms.Button
            $RemoveButton.Location = New-Object System.Drawing.Point(($BorderSize), ($ListView.Bottom + $BorderSize)) # Position under the ListView
            $RemoveButton.Size = New-Object System.Drawing.Size(($FilterPanelWidth - $BorderSize), 30) # Adjust the size of the button
            $RemoveButton.Text = "Remove filter" # Set the text of the button
            $RemoveButton.Font = New-Object System.Drawing.Font($Font, $FontSize)  # Apply the same font and size as in the function

            # Action when clicking "Remove"
            $RemoveButton.Add_Click({
                # Check if an item is selected in the ListView
                If ($ListView.SelectedItems.Count -gt 0)
                {
                    # Retrieve the selected item
                    $selectedItem = $ListView.SelectedItems[0]

                    # Remove the item from the ListView
                    $ListView.Items.Remove($selectedItem)

                    # Filter the data and update the DataGridView
                    $filteredData = $AllData | Where-Object { $_.Nom -ne $selectedItem.Text }

                    Update-DataSource
                }
                Else
                {
                    [System.Windows.Forms.MessageBox]::Show("Please select an item to remove.")
                }
            })
            # Add the button to the form
            $Form.Controls.Add($RemoveButton)

            # Create the "Export to CSV" button
            $ExportButton = New-Object System.Windows.Forms.Button
            $ExportButton.Location = New-Object System.Drawing.Point(($BorderSize), ($RemoveButton.Bottom + $BorderSize))
            $ExportButton.Size = New-Object System.Drawing.Size(($FilterPanelWidth - $BorderSize), 30)
            $ExportButton.Text = "Export to CSV"
            $ExportButton.Font = New-Object System.Drawing.Font($Font, $FontSize)

            # Action when clicking "Export to CSV"
            $ExportButton.Add_Click({
                $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
                $SaveFileDialog.Filter = "CSV files (*.csv)|*.csv"
                $SaveFileDialog.Title = "Choose a location and name for the CSV file"

                # Show the dialog to choose the file location and name
                If ($SaveFileDialog.ShowDialog() -eq 'OK')
                {
                    # Retrieve the file location and name
                    $CsvFilePath = $SaveFileDialog.FileName

                    # Prepare the data to export
                    $ExportData = @()

                    # Retrieve the columns of the DataGridView
                    $Columns = $DataGridView.Columns

                    # Create the CSV header
                    $Header = @()
                    Foreach ($Column in $Columns)
                    {
                        $Header += $Column.HeaderText
                    }
                    $ExportData += [string]::Join(";", $Header)  # Use ; as the separator

                    # Retrieve the rows of the DataGridView and add them to the data array
                    Foreach ($Row in $DataGridView.Rows)
                    {
                        $RowData = @()
                        Foreach ($Column in $Columns)
                        {
                            # Add the value of each cell to the row
                            $RowData += $Row.Cells[$Column.Index].Value
                        }
                        # Add the row to the data array
                        $ExportData += [string]::Join(";", $RowData)  # Use ; as the separator
                    }

                    # Save the data as a CSV file
                    $ExportData | Out-File -FilePath $CsvFilePath -Encoding UTF8

                    # Show a confirmation message
                    [System.Windows.Forms.MessageBox]::Show("CSV file exported successfully to: $CsvFilePath", "Export Successful")
                }
            })

            # Add the button to the form
            $Form.Controls.Add($ExportButton)

            $Form.Add_Shown({$Form.Activate()})
            [Void]$Form.ShowDialog()
        }
    }
}
