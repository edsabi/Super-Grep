[CmdletBinding()]
param (
    [Parameter()]
    [string]$Path = "",
    [Parameter(Mandatory=$true)]
    [string]$String,
    [int]$SleepDurationInSeconds = 2
)

if ($Path -eq "") {
    $Path = (Resolve-Path .).Path
}

$alreadyPrintedCodeBlocks = @{}

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
                Write-Host "Found '$String' in file: $filePath"
                Write-Host "Line number: $($i + 1)"
                
                try {
                    Write-Host "Code block:"
                    $codeBlock | ForEach-Object { Write-Host "$_" }
                    Write-Host ""

                    # Sleep for the specified duration
                    Start-Sleep -Seconds $SleepDurationInSeconds

                    # Mark the code block as printed
                    $alreadyPrintedCodeBlocks[$codeBlockString] = $true
                }
                catch {
                    Write-Host "Error printing code block at line $($i + 1) in file: $filePath`n"
                }
            }
        }
    }
}
