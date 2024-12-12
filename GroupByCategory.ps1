# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Define input file
$inputFile = "./categorized_arabic_words.json"

# Define output file name pattern
$outputFilePattern = "./grouped_words/{0}.json"

# Load the categorized words
Write-Output "Loading categorized words from $inputFile..."
$categorizedWords = Get-Content -Path $inputFile -Raw | ConvertFrom-Json

# Group words by the 'category' property
Write-Output "Grouping words by category..."
$groupedWords = $categorizedWords | Group-Object -Property category

# Save each group to a separate file
foreach ($group in $groupedWords) {
    $category = $group.Name -replace '\s+', '_'  # Replace spaces with underscores for file naming
    $outputFile = $outputFilePattern -f $category

    Write-Output "Saving group '$category' to $outputFile..."
    $group.Group | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFile -Encoding UTF8
}

Write-Output "Done! Grouped words saved to individual files."
