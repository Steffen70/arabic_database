# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Input and output file paths
$inputFile = "./grouped_words/adjective.json"
$outputFile = "./grouped_words/adjective.csv"

# Gender abbreviation mapping
$genderAbbrevMap = @{
    "male"   = "M";
    "female" = "F"
}

# Function to safely get gender abbreviation
function Get-GenderAbbrev {
    param([string]$gender)
    return $genderAbbrevMap[$gender] ?? ""  # Empty string if null or unknown
}

# Function to normalize Arabic text (remove diacritics)
function Remove-Diacritics {
    param ([string]$text)
    return $text -replace "[ًٌٍَُِّْ]", ""
}

# Load the input JSON file
Write-Output "Loading adjective data from $inputFile..."
$adjectives = Get-Content -Path $inputFile -Raw | ConvertFrom-Json

# Initialize CSV content
$outputLines = @()

# Process each adjective
foreach ($adjective in $adjectives) {
    $arabicWord = $adjective.arabic_word
    $baseForm = $adjective.base_form ?? ""
    $translation = $adjective.translation
    $genderAbbrev = Get-GenderAbbrev -gender $adjective.gender

    # Normalize Arabic words (strip diacritics)
    $normalizedArabicWord = Remove-Diacritics -text $arabicWord
    $normalizedBaseForm = Remove-Diacritics -text $baseForm

    # Only include /$base_form if it differs from the normalized arabic word
    if ($normalizedArabicWord -ne $normalizedBaseForm -and $baseForm) {
        $formattedLine = "$arabicWord/$baseForm;$translation ($genderAbbrev)".Trim()
    }
    else {
        $formattedLine = "$arabicWord;$translation ($genderAbbrev)".Trim()
    }

    # Add to output lines
    $outputLines += $formattedLine
}

# Save the output lines to CSV
Write-Output "Saving formatted adjectives to $outputFile..."
$outputLines | Set-Content -Path $outputFile -Encoding UTF8

Write-Output "Done! Adjective data saved to $outputFile."
