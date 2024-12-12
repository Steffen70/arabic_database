# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Input and output file paths
$inputFile = "./grouped_words/verb.json"
$outputFile = "./grouped_words/verb.csv"

# Tense abbreviation mapping
$tenseAbbrevMap = @{
    "Present simple"     = "PRS";
    "Present continuous" = "PRC";
    "Past simple"        = "PST";
    "Past continuous"    = "PSC";
    "Past perfect"       = "PPF";
    "Future"             = "FUT";
    "Imperative"         = "IMP"
}

# Possession abbreviation mapping
$possessionAbbrevMap = @{
    "first person singular"   = "1PS";
    "first person plural"     = "1PP";
    "second person singular"  = "2PS";
    "second person plural"    = "2P";
    "third person singular"   = "3S";
    "third person plural"     = "3P"
}

# Function to safely get abbreviations
function Get-TenseAbbrev {
    param([string]$tense)
    return $tenseAbbrevMap[$tense] ?? "UNK"  # Default to 'UNK' if unknown
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
Write-Output "Loading verb data from $inputFile..."
$verbs = Get-Content -Path $inputFile -Raw | ConvertFrom-Json

# Initialize CSV content
$outputLines = @()

# Process each verb
foreach ($verb in $verbs) {
    $arabicWord = $verb.arabic_word
    $baseForm = $verb.base_form ?? ""
    $translation = $verb.translation
    $tenseAbbrev = Get-TenseAbbrev -tense $verb.tense
    $possessionAbbrev = Get-PossessionAbbrev -possession $verb.possession

    # Normalize Arabic words (strip diacritics)
    $normalizedArabicWord = Remove-Diacritics -text $arabicWord
    $normalizedBaseForm = Remove-Diacritics -text $baseForm

    # Only include /$base_form if it differs from the normalized arabic word
    if ($normalizedArabicWord -ne $normalizedBaseForm -and $baseForm) {
        $formattedLine = "$arabicWord/$baseForm;$translation ($tenseAbbrev $possessionAbbrev".Trim() + ")"
    }
    else {
        $formattedLine = "$arabicWord;$translation ($tenseAbbrev $possessionAbbrev".Trim() + ")"
    }

    # Add to output lines
    $outputLines += $formattedLine
}

# Save the output lines to CSV
Write-Output "Saving formatted verbs to $outputFile..."
$outputLines | Set-Content -Path $outputFile -Encoding UTF8

Write-Output "Done! Verb data saved to $outputFile."
