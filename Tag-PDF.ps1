param($inputFile, $outputFile) 

Add-Type -Path "$($PSScriptRoot)\PdfSharp\PdfSharp-WPF.dll"

$watermark = "NERC CIP CONFIDENTIAL"

#  Get a PDF Document
$PdfReader = [PdfSharp.Pdf.IO.PdfReader] 
$PdfDocumentOpenMode = [PdfSharp.Pdf.IO.PdfDocumentOpenMode]
$document = New-Object PdfSharp.Pdf.PdfDocument            
$document = $PdfReader::Open($inputFile, $PdfDocumentOpenMode::Modify) 

$document.pages | % {
	$gfx = [PdfSharp.Drawing.XGraphics]::FromPdfPage($_)
	$options = New-Object PdfSharp.Drawing.XPdfFontOptions([PdfSharp.Pdf.PdfFontEncoding]"Unicode",
														   [PdfSharp.Pdf.PdfFontEmbedding]"Always")
	$font = New-Object PdfSharp.Drawing.XFont("Arial", 20, [PdfSharp.Drawing.XFontStyle]"Bold", $options)
	$xcolor = [PdfSharp.Drawing.XColor]::FromArgb(30, 255, 0, 0)
	$brush = New-Object PdfSharp.Drawing.XSolidBrush($xcolor)
	$gfx.DrawString($watermark,
					$font,
					$brush,
					(new-object PdfSharp.Drawing.XRect(0, 0, $_.Width, $_.Height)),
					[PdfSharp.Drawing.XStringFormats]::Center)
}

# Save the document...
$document.Save($outputFile)