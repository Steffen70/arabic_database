# Define input/output files
$inputFile = "./distinct_arabic_words.json"
$outputFile = "./categorized_arabic_words.json"
$failedOutputFile = "./failed_words.json"
$promptFile = "./gpt_prompt.md"

# API Configuration
$apiKey = "YOUR_OPENAI_API_KEY" 
$apiUrl = "https://api.openai.com/v1/chat/completions"
$model = "gpt-4o"

# Delay to respect rate limits (120 ms for ~8 requests per second)
$delayMs = 120

# Read input words and prompt template
$words = Get-Content -Path $inputFile -Raw | ConvertFrom-Json
$promptTemplate = Get-Content -Path $promptFile -Raw

# Initialize an empty list for output and failed words
$outputList = @()
$failedWords = @()

# Loop through each word
foreach ($word in $words) {
    Write-Output "Processing word: $word"

    # Replace %input% with the actual word in the prompt
    $prompt = $promptTemplate -replace "%input%", $word

    # Prepare the API request body
    $requestBody = @{
        model = $model
        messages = @(
            @{ role = "user"; content = $prompt }
        )
        max_tokens = 200
    } | ConvertTo-Json -Depth 10

    try {
        # Call the GPT-4o API
        $response = Invoke-RestMethod -Uri $apiUrl `
            -Headers @{ "Authorization" = "Bearer $apiKey"; "Content-Type" = "application/json" } `
            -Method POST `
            -Body $requestBody

        # Debug: Print raw API response
        Write-Output "Raw API Response: $($response | ConvertTo-Json -Depth 10)"

        # Extract and clean up the content (strip code block markers and line breaks)
        $content = $response.choices[0].message.content -replace "``````json", "" -replace "``````", "" -replace "\r?\n", "" -replace "\n", ""

        # Parse the cleaned content as JSON
        $jsonContent = $content | ConvertFrom-Json

        # Add the original Arabic word to the response object
        $jsonContent | Add-Member -MemberType NoteProperty -Name "arabic_word" -Value $word

        # Append to the output list
        $outputList += $jsonContent

        # Add delay to respect rate limits
        Start-Sleep -Milliseconds $delayMs
    }
    catch {
        Write-Error "Error processing word '$word': $_"
        # Add the failed word to the list
        $failedWords += $word
    }
}

# Export the categorized words to a JSON file
Write-Output "Saving results to $outputFile"
$outputList | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFile -Encoding UTF8

# Export failed words to a separate JSON file
if ($failedWords.Count -gt 0) {
    Write-Output "Saving failed words to $failedOutputFile"
    $failedWords | ConvertTo-Json -Depth 1 | Set-Content -Path $failedOutputFile -Encoding UTF8
    Write-Output "Failed words saved to $failedOutputFile"
} else {
    Write-Output "No failed words encountered!"
}

Write-Output "Done! Categorized words saved to $outputFile."
