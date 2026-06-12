# Deploy worker + set API_DEEPSEEK_KEY secret.
# Usage: .\scripts\Deploy-Worker.ps1 -ApiKey "sk-..."
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiKey
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

& "$PSScriptRoot\Set-WorkerSecret.ps1" -ApiKey $ApiKey

Write-Host "Deploying worker hyperliquiddrinksmarter-api-proxy..."
npx wrangler deploy
if ($LASTEXITCODE -ne 0) {
    throw "wrangler deploy failed"
}

Write-Host ""
Write-Host "Worker URL (default): https://hyperliquiddrinksmarter-api-proxy.<your-subdomain>.workers.dev"
Write-Host "Set HyperliquidDrinkSmarterAPIBaseURL in Info.plist to that URL (no trailing slash)."
Write-Host "Health check: GET {baseURL}/health"
