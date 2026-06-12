# Sets API_DEEPSEEK_KEY on the deployed Cloudflare Worker (non-interactive).
# Usage: .\scripts\Set-WorkerSecret.ps1 -ApiKey "sk-..."
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiKey
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    throw "npx not found. Install Node.js first."
}

Write-Host "Checking Cloudflare login..."
npx wrangler whoami
if ($LASTEXITCODE -ne 0) {
    throw "Not logged in. Run: npx wrangler login"
}

Write-Host "Uploading secret API_DEEPSEEK_KEY..."
$ApiKey | npx wrangler secret put API_DEEPSEEK_KEY
if ($LASTEXITCODE -ne 0) {
    throw "wrangler secret put failed"
}

Write-Host "Done. Verify with: npx wrangler dev (local) or curl {workerURL}/health"
