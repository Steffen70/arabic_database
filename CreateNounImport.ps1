# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Input and output file paths
$inputFile = "./grouped_words/noun.json"
$outputFile = "./grouped_words/noun.csv"

# Gender abbreviation mapping
$genderAbbrevMap = @{
    "male"   = "M";
    "female" = "F"
}

# Number abbreviation mapping
$numberAbbrevMap = @{
    "singular" = "SG";
    "dual"     = "DU";
    "plural"   = "PL"
}

# Possession abbreviation mapping
$possessionAbbrevMap = @{
    "first person singular"   = "1S";
    "first person plural"     = "1P";
    "second person singular"  = "2S";
    "second person plural"    = "2P";
    "third person singular"   = "3S";
    "third person plural"     = "3P"
}

# Function to safely get abbreviations
function Get-GenderAbbrev {
    param([string]$gender)
    return $genderAbbrevMap[$gender] ?? ""  # Empty string if null or unknown
}

function Get-NumberAbbrev {
    param([string]$number)
    return $numberAbbrevMap[$number] ?? ""  # Empty string if null or unknown
}

function Get-PossessionAbbrev {
    param([string]$possession)
    return $possessionAbbrevMap[$possession] ?? ""  # Empty string if null or unknown
}

# Function to normalize Arabic text (remove diacritics)
function Remove-Diacritics {
    param ([string]$text)
    return $text -replace "[ًٌٍَُِّْ]", ""
}

# Load the input JSON file
Write-Output "Loading noun data from $inputFile..."
$nouns = Get-Content -Path $inputFile -Raw | ConvertFrom-Json

# Initialize CSV content
$outputLines = @()

# Process each noun
foreach ($noun in $nouns) {
    $arabicWord = $noun.arabic_word
    $baseForm = $noun.base_form ?? ""
    $translation = $noun.translation
    $genderAbbrev = Get-GenderAbbrev -gender $noun.gender
    $numberAbbrev = Get-NumberAbbrev -number $noun.number
    $possessionAbbrev = Get-PossessionAbbrev -possession $noun.possession

    # Normalize Arabic words (strip diacritics)
    $normalizedArabicWord = Remove-Diacritics -text $arabicWord
    $normalizedBaseForm = Remove-Diacritics -text $baseForm

    # Only include /$base_form if it differs from the normalized arabic word
    if ($normalizedArabicWord -ne $normalizedBaseForm -and $baseForm) {
        $formattedLine = "$arabicWord/$baseForm;$translation ($genderAbbrev $numberAbbrev $possessionAbbrev".Trim() + ")"
    }
    else {
        $formattedLine = "$arabicWord;$translation ($genderAbbrev $numberAbbrev $possessionAbbrev".Trim() + ")"
    }

    # Add to output lines
    $outputLines += $formattedLine
}

# Save the output lines to CSV
Write-Output "Saving formatted nouns to $outputFile..."
$outputLines | Set-Content -Path $outputFile -Encoding UTF8

Write-Output "Done! Noun data saved to $outputFile."
