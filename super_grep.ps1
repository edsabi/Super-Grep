[CmdletBinding()]
param (
    [Parameter()]
    [string]$Path = "",
    [Parameter()]
    [string]$String,
    [Parameter()]
    [string]$OutputFile,
    [int]$SleepDurationInSeconds = 2,
    [Parameter()]
    [switch]$Help
)

function Show-Help {
    @"
Usage:
    .\code_scraper.ps1 [-Path <Path>] -String <String> [-OutputFile <OutputFile>] [-SleepDurationInSeconds <SleepDurationInSeconds>] [-Help]

Options:
    -Path <Path>                      : The path to search for files (default is the current path).
    -String <String>                  : The string to search for in the files (mandatory).
    -OutputFile <OutputFile>          : The output file to save the results (optional, results will be printed to console if not provided).
    -SleepDurationInSeconds <Seconds> : The number of seconds to sleep between code blocks (default is 2).
    -Help                             : Show this help message.

Examples:
    .\code_scraper.ps1 -String "svg"
    .\code_scraper.ps1 -Path "C:\path\to\your\folder" -String "svg" -OutputFile "output.txt" -SleepDurationInSeconds 3
"@
}

if ($Help -or ($String -eq "")) {
    if ($String -eq "") {
        Write-Host "Error: The -String parameter is mandatory.`n" -ForegroundColor Red
    }
    Show-Help
    exit
}

if ($Path -eq "") {
    $Path = (Resolve-Path .).Path
}

$alreadyPrintedCodeBlocks = @{}
$outputData = @()

Get-ChildItem -Path $Path -Recurse -File | ForEach-Object {
    $filePath = $_.FullName
    $fileContent = Get-Content -Path $filePath

    for ($i = 0; $i -lt $fileContent.Count; $i++) {
        $line = $fileContent[$i]

        if ($line -match $String) {
            $startIndex = $i - 1
            while ($startIndex -ge 0 -and $fileContent[$startIndex] -notmatch '^\s*$') {
                $startIndex--
            }

            $endIndex = $i + 1
            while ($endIndex -lt $fileContent.Count -and $fileContent[$endIndex] -notmatch '^\s*$') {
                $endIndex++
            }

            $codeBlock = ($startIndex + 1)..($endIndex - 1) | ForEach-Object { $fileContent[$_] }
            $codeBlockString = $codeBlock -join "`n"

            if (-not $alreadyPrintedCodeBlocks.ContainsKey($codeBlockString)) {
                $output = "Found '$String' in file: $filePath`nLine number: $($i + 1)`nCode block:`n$codeBlockString`n"
                $outputData += $output

                if (-not $OutputFile) {
                    Write-Host $output
                    
                    # Sleep for the specified duration
                    Start-Sleep -Seconds $SleepDurationInSeconds
                }

                # Mark the code block as printed
                $alreadyPrintedCodeBlocks[$codeBlockString] = $true
            }
        }
    }
}

if ($OutputFile) {
    $outputData | Set-Content -Path $OutputFile
}
