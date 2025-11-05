# PowerShell script to load .env file into environment variables
# Usage: . .\load-env.ps1

param(
    [string]$EnvFile = ".env"
)

function Load-EnvFile {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Warning ".env file not found at: $Path"
        Write-Host "Creating from template..."

        if (Test-Path ".env.example") {
            Copy-Item ".env.example" $Path
            Write-Host "✅ Created .env from .env.example"
            Write-Host "⚠️  Please edit .env and fill in your actual values!"
            Write-Host ""
            return $false
        } else {
            Write-Error ".env.example not found. Cannot create .env"
            return $false
        }
    }

    Write-Host "Loading environment variables from: $Path"

    $envVars = @{}
    $lineNumber = 0

    Get-Content $Path | ForEach-Object {
        $lineNumber++
        $line = $_.Trim()

        # Skip empty lines and comments
        if ($line -eq "" -or $line.StartsWith("#")) {
            return
        }

        # Parse KEY=VALUE
        if ($line -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()

            # Remove quotes if present
            $value = $value -replace '^"(.*)"$', '$1'
            $value = $value -replace "^'(.*)'$", '$1'

            # Check for placeholder values
            if ($value -match 'YOUR_.*_HERE' -or $value -match 'your_.*_here') {
                Write-Warning "Line $lineNumber: $key has placeholder value - please update!"
            }

            # Set environment variable
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
            $envVars[$key] = $value

        } else {
            Write-Warning "Line $lineNumber: Invalid format (expected KEY=VALUE): $line"
        }
    }

    Write-Host ""
    Write-Host "✅ Loaded $($envVars.Count) environment variables"
    Write-Host ""

    # Show loaded variables (masked)
    Write-Host "Loaded variables:"
    $envVars.GetEnumerator() | Sort-Object Name | ForEach-Object {
        $displayValue = if ($_.Value.Length -gt 20) {
            $_.Value.Substring(0, 20) + "..." + $_.Value.Substring($_.Value.Length - 4)
        } else {
            "****"
        }
        Write-Host "  $($_.Key) = $displayValue"
    }

    Write-Host ""
    return $true
}

# Load the .env file
$loaded = Load-EnvFile -Path $EnvFile

if ($loaded) {
    Write-Host "✅ Environment variables loaded successfully!"
    Write-Host ""
    Write-Host "You can now use them in your scripts:"
    Write-Host '  $env:ANTHROPIC_API_KEY'
    Write-Host '  $env:VPS_HOST'
    Write-Host '  $env:TELEGRAM_BOT_TOKEN'
    Write-Host ""
} else {
    Write-Host "❌ Failed to load environment variables"
    Write-Host "Please ensure .env exists and has valid KEY=VALUE pairs"
}
