# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Define input and output files
$inputFile = "./cleaned_arabic_words.json"
$outputFile = "./distinct_arabic_words.json"

# Function to remove diacritics from an Arabic word
function Remove-ArabicDiacritics {
    param ([string]$word)
    # Remove fatha, damma, kasra, sukun, shadda, and their tanween
    return $word -replace "[ًٌٍَُِّْ]", ""  
}

# Function to count diacritics in an Arabic word
function Count-ArabicDiacritics {
    param ([string]$word)
    $diacriticMatches = ([regex]::Matches($word, "[ًٌٍَُِّْ]")).Count
    return $diacriticMatches
}

# Function to filter distinct words, keeping the version with the most diacritics
function Get-DistinctArabicWords {
    param ([string[]]$words)

    $distinctMap = @{}

    foreach ($word in $words) {
        $baseWord = Remove-ArabicDiacritics -word $word
        $diacriticCount = Count-ArabicDiacritics -word $word

        if (-not $distinctMap.ContainsKey($baseWord)) {
            # If base word is not already in the map, add it
            $distinctMap[$baseWord] = @{
                Word = $word
                DiacriticCount = $diacriticCount
            }
        } elseif ($distinctMap[$baseWord].DiacriticCount -lt $diacriticCount) {
            # If base word exists but current word has more diacritics, replace it
            $distinctMap[$baseWord] = @{
                Word = $word
                DiacriticCount = $diacriticCount
            }
        }
    }

    # Return only the words with the most diacritics
    return $distinctMap.Values.Word
}

# Main Execution
Write-Output "Reading cleaned Arabic words from JSON..."
$cleanedWords = Get-Content -Path $inputFile -Raw | ConvertFrom-Json

Write-Output "Filtering distinct Arabic words with the most diacritics..."
$distinctWords = Get-DistinctArabicWords -words $cleanedWords

Write-Output "Exporting distinct Arabic words to JSON..."
$distinctWords | ConvertTo-Json -Depth 1 | Set-Content -Path $outputFile -Encoding UTF8

Write-Output "Done! Distinct Arabic words saved to $outputFile."
