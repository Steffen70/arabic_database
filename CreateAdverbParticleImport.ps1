# Stop execution if any error occurs
$ErrorActionPreference = "Stop"

# Input and output file paths
$adverbInputFile = "./grouped_words/adverb.json"
$particleInputFile = "./grouped_words/particle.json"
$outputFile = "./grouped_words/adverb_particle.csv"

# Load and combine input files
Write-Output "Loading adverb data from $adverbInputFile..."
$adverbs = Get-Content -Path $adverbInputFile -Raw | ConvertFrom-Json

Write-Output "Loading particle data from $particleInputFile..."
$particles = Get-Content -Path $particleInputFile -Raw | ConvertFrom-Json

Write-Output "Combining adverb and particle data..."
$combinedWords = $adverbs + $particles

# Initialize CSV content
$outputLines = @()

# Process each word (adverb or particle)
foreach ($word in $combinedWords) {
    $arabicWord = $word.arabic_word
    $translation = $word.translation

    # Format the line: $arabic_word;$translation
    $formattedLine = "$arabicWord;$translation".Trim()

    # Add to output lines
    $outputLines += $formattedLine
}

# Save the output lines to CSV
Write-Output "Saving combined data to $outputFile..."
$outputLines | Set-Content -Path $outputFile -Encoding UTF8

Write-Output "Done! Adverb and particle data saved to $outputFile."
