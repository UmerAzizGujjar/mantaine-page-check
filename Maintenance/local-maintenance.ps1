# Local maintenance switch for this repository's IIS Express site.
#
#   .\Maintenance\local-maintenance.ps1 WARNING       banner only, app stays usable
#   .\Maintenance\local-maintenance.ps1 MAINTENANCE   app closed, offline page shown
#   .\Maintenance\local-maintenance.ps1 RUNNING       everything back to normal
#
# Operates on GL\ (the local application root). Never commit the files it creates:
# GL\app_offline.htm and GL\maintenance\status.txt are in .gitignore.

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("WARNING", "MAINTENANCE", "RUNNING")]
    [string]$State
)

$ErrorActionPreference = "Stop"

$app = Join-Path (Split-Path -Parent $PSScriptRoot) "GL"
$mnt = Join-Path $app "maintenance"
$offline = Join-Path $app "app_offline.htm"
$source = Join-Path $PSScriptRoot "app_offline.htm"

if (-not (Test-Path (Join-Path $app "Web.config"))) {
    throw "Application root not found: $app"
}

New-Item -ItemType Directory -Path $mnt -Force | Out-Null

function Set-Status([string]$value) {
    # Atomic write: a browser must never read a half-written status file.
    $tmp = Join-Path $mnt "status.txt.tmp"
    Set-Content -Path $tmp -Value $value -Encoding ASCII -NoNewline
    Move-Item -Path $tmp -Destination (Join-Path $mnt "status.txt") -Force
}

# The file changes BEFORE the status:
#   going down  -> app_offline.htm exists before anyone is told "MAINTENANCE", so the open tab's
#                  frame always finds the page instead of a 404
#   coming back -> the 503 is gone before "RUNNING" is written, so a polling tab cannot bounce
#                  back into the offline page
if ($State -eq "MAINTENANCE") {
    Copy-Item $source $offline -Force
    Set-Status "MAINTENANCE"
} else {
    Remove-Item $offline -Force -ErrorAction SilentlyContinue
    Set-Status $State
}

Write-Host "Status: $State" -ForegroundColor Green
Write-Host "Offline page active: $(Test-Path $offline)"
Write-Host "Open: http://localhost:28402/Login.aspx"
