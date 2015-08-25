param(
	[string]$fileType
)

Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$ExcelFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault

if ($fileType -match ".xlsx*$") {
	$Excel = New-Object -ComObject Excel.Application
	Get-ChildItem $fileType | % {
		$worksheet = $Excel.Workbooks.Item(1)
		$row = $worksheet.Cells.Item(1, 1).entireRow
		$row.Activate()
		$row.Insert(-4121)
		$row.Insert(-4121)
		$worksheet.Cells.Item(1, 1) = "NERC CIP CONFIDENTIAL"
		
		$Excel.ActiveWorkbook.SaveAs($_.FullName, $ExcelFormat)
	}
	$Excel.Quit()
} else { Get-ChildItem -Recurse $fileType | % {
	$text = [IO.File]::ReadAllText($_) -replace "`n", "`r`n"  
	if (!($text -match ".*NERC CIP CONFIDENTIAL.*")) {
		[IO.File]::WriteAllText($_, "NERC CIP CONFIDENTIAL" + [System.Environment]::NewLine + [System.Environment]::NewLine + $text)
		Write-Output "Processed $_"
	}		
	}
}