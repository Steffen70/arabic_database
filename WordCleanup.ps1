# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Define input and output files
$inputFile = "./words.json"
$outputFile = "./cleaned_arabic_words.json"

# Function to clean, split, and filter Arabic words/sentences
function Clean-ArabicText {
    param ([string[]]$lines)

    # Arabic letters range
    $arabicPattern = "[\u0600-\u06FF]+"

    # Delimiters to split lines
    $splitDelimiters = "[=+*():;,/\\\-\u2013\u2014]+"

    # Emojis and symbols
    $emojiPattern = "[\p{So}|\p{Cn}|\p{Cs}|\p{Co}]"

    # European letters
    $europeanTextPattern = "[a-zA-ZäöüÄÖÜß><.]+"

    # European numbers (0-9)
    $europeanNumbersPattern = "\d+"

    # Elongation character
    $elongationPattern = "ـ"

    # Strings that contain only diacritics
    $diacriticsOnlyPattern = "^[ًٌٍَُِّْ\s]+$"

    # Single Arabic letter with diacritics
    $singleArabicWithDiacritics = "^[\u0600-\u06FF][ًٌٍَُِّْ]?$" 

    # Single Arabic letter + space/punctuation
    $singleArabicWithPunctuation = "^[\u0600-\u06FF][ًٌٍَُِّْ]?\s?\p{P}+$" 

    # Exclude "ءا" and "اء"
    $hamzaCombinationPattern = "^(ءا|اء)$"

    $cleanedList = @()

    foreach ($line in $lines) {
        # Split line using delimiters and iterate over words
        $splitWords = $line -split $splitDelimiters
        foreach ($word in $splitWords) {
            # Final space and line break cleanup
            $trimmedWord = $word.Trim() -replace "`r?`n", ""

            # Apply filters
            if ($trimmedWord -match $arabicPattern -and `
                $trimmedWord -notmatch $europeanTextPattern -and `
                $trimmedWord -notmatch $europeanNumbersPattern -and `
                $trimmedWord -notmatch $emojiPattern -and `
                $trimmedWord -notmatch $elongationPattern -and `
                $trimmedWord -notmatch $singleArabicWithDiacritics -and `
                $trimmedWord -notmatch $singleArabicWithPunctuation -and `
                $trimmedWord -notmatch $diacriticsOnlyPattern -and `
                $trimmedWord -notmatch $hamzaCombinationPattern) {
                $cleanedList += $trimmedWord
            }
        }
    }
    return ($cleanedList | Select-Object -Unique)
}

# Main Execution
Write-Output "Reading raw words from JSON..."
$rawWords = Get-Content -Path $inputFile -Raw | ConvertFrom-Json

Write-Output "Cleaning and filtering Arabic words..."
$cleanedWords = Clean-ArabicText -lines $rawWords

Write-Output "Exporting cleaned words to JSON..."
$cleanedWords | ConvertTo-Json -Depth 1 | Set-Content -Path $outputFile -Encoding UTF8

Write-Output "Done! Cleaned words saved to $outputFile."
