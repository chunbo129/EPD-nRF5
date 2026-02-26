<#
.SYNOPSIS
    Generates a DFU package for the nRF52 firmware.
.DESCRIPTION
    This script uses nrfutil to generate a zip package containing the application firmware.
    It requires nrfutil to be installed (pip install nrfutil).
#>

$ErrorActionPreference = "Stop"

# Configuration
$HEX_FILE = "_build_nrf52/nrf52811_xxaa.hex"
$OUT_FILE = "_build_nrf52/app_dfu_package.zip"
$KEY_FILE = "tools/priv.pem"
$SD_REQ   = "0x126,0x103" # S112 v7.3.0 (0x126) and v7.2.0 (0x103)
$APP_VER  = 2        # Application version (increment this for updates)

# Note: nrfutil (classic) has compatibility issues with Python 3.11+.
# It is recommended to use Python 3.9 if you encounter errors.


# Check if hex file exists
if (-not (Test-Path $HEX_FILE)) {
    Write-Error "Hex file not found: $HEX_FILE. Please build the project first."
}

# Check if key file exists
if (-not (Test-Path $KEY_FILE)) {
    Write-Error "Private key file not found: $KEY_FILE."
}

# Check for nrfutil
if (-not (Get-Command "nrfutil" -ErrorAction SilentlyContinue)) {
    Write-Warning "nrfutil not found in PATH. Attempting to install via pip..."
    try {
        pip install nrfutil
    }
    catch {
        Write-Error "Failed to install nrfutil. Please install it manually: pip install nrfutil"
    }
}

# Generate package
Write-Host "Generating DFU package..."
nrfutil pkg generate --hw-version 52 --application-version $APP_VER --application $HEX_FILE --sd-req $SD_REQ --key-file $KEY_FILE $OUT_FILE

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! DFU package created at: $OUT_FILE"
} else {
    Write-Error "Failed to generate DFU package."
}
