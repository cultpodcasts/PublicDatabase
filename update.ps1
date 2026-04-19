[CmdletBinding()]
param(
    [datetime]$CommitDate = (Get-Date),
    [switch]$SkipPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ExternalCommand {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [switch]$CaptureOutput,

        [Parameter(Mandatory)]
        [string]$Description
    )

    if ($CaptureOutput) {
        $output = & $FilePath @Arguments
    }
    else {
        & $FilePath @Arguments
        $output = $null
    }

    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE."
    }

    return $output
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$publisherBasePath = Join-Path $repoRoot '..\cultpodcasts\RedditPodcastPoster\Console-Apps\cultPodcasts.DatabasePublisher\bin\Debug\net10.0\CultPodcasts.DatabasePublisher'
$publisherPath = @(
    $publisherBasePath,
    "$publisherBasePath.exe"
) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1

if (-not $publisherPath) {
    throw "Could not find CultPodcasts.DatabasePublisher next to this repo. Expected '$publisherBasePath' or '$publisherBasePath.exe'."
}

$commitMessage = 'New episodes {0}' -f $CommitDate.ToString('d MMMM yyyy', [System.Globalization.CultureInfo]::GetCultureInfo('en-GB'))

Push-Location $repoRoot

try {
    Write-Host "Deleting existing JSON files..."
    Get-ChildItem -LiteralPath $repoRoot -Filter '*.json' -File | Remove-Item -Force

    Write-Host "Running CultPodcasts.DatabasePublisher --use-v2..."
    Invoke-ExternalCommand -FilePath $publisherPath -Arguments @('--use-v2') -Description 'Publishing database'

    Write-Host "Staging changes..."
    Invoke-ExternalCommand -FilePath 'git' -Arguments @('add', '-A') -Description 'Staging git changes' | Out-Null

    $status = Invoke-ExternalCommand -FilePath 'git' -Arguments @('status', '--porcelain') -CaptureOutput -Description 'Checking git status'

    if (-not $status) {
        Write-Host 'No changes detected after publishing. Skipping commit and push.'
        return
    }

    Write-Host "Creating commit: $commitMessage"
    Invoke-ExternalCommand -FilePath 'git' -Arguments @('commit', '-m', $commitMessage) -Description 'Creating git commit' | Out-Null

    if ($SkipPush) {
        Write-Host 'Skipping git push because -SkipPush was supplied.'
        return
    }

    Write-Host 'Pushing to remote...'
    Invoke-ExternalCommand -FilePath 'git' -Arguments @('push') -Description 'Pushing git changes' | Out-Null
}
finally {
    Pop-Location
}
