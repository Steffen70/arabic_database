# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Define input and output files
$inputFile = "./arabic_nader.odt"
$outputFile = "./words.json"

# Function to extract all Arabic text and table cells from the content
function Extract-ArabicContent {
    param ([string]$filePath)

    # Step 1: Unzip the ODT file to access content.xml
    $tempDir = "Temp_ODT_Extraction"
    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
    Expand-Archive -Path $filePath -DestinationPath $tempDir -Force

    # Step 2: Extract all text content from content.xml
    $contentPath = Join-Path $tempDir "content.xml"
    if (-Not (Test-Path $contentPath)) {
        Write-Error "Could not locate content.xml inside the ODT file."
    }

    # Read the XML content with namespaces
    $xmlContent = [xml](Get-Content -Path $contentPath -Raw)
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.NameTable)
    $namespaceManager.AddNamespace("text", "urn:oasis:names:tc:opendocument:xmlns:text:1.0")

    # Extract <text:p> and <text:table-cell> content
    $paragraphs = $xmlContent.SelectNodes("//text:p", $namespaceManager)
    $tableCells = $xmlContent.SelectNodes("//text:table-cell", $namespaceManager)

    # Combine all text, replacing newlines in table cells with spaces
    $result = @()
    foreach ($node in $paragraphs) { $result += $node.InnerText }
    foreach ($cell in $tableCells) {
        $cellText = $cell.InnerText -replace "`r?`n", " "  # Replace newlines in table cells
        $result += $cellText
    }

    Remove-Item -Recurse -Force $tempDir  # Cleanup temporary directory
    return $result
}

# Main Execution
Write-Output "Extracting text content from ODT file..."
$fullText = Extract-ArabicContent -filePath $inputFile

Write-Output "Exporting raw words to JSON..."
$fullText | ConvertTo-Json -Depth 1 | Set-Content -Path $outputFile -Encoding UTF8

Write-Output "Done! Raw words saved to $outputFile."
