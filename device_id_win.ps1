# Generate new IDs
$new_machine_id = -join ((1..64) | ForEach-Object { "0123456789abcdef"[(Get-Random -Max 16)] })
$new_dev_device_id = [guid]::NewGuid().ToString().ToLower()
$new_mac_machine_id = [guid]::NewGuid().ToString().ToLower()
$new_sqm_id = "{" + [guid]::NewGuid().ToString().ToUpper() + "}"

# File paths
$storage_json_path = "$env:APPDATA\Cursor\User\globalStorage\storage.json"
$backup_dir = "$env:APPDATA\Cursor\User\globalStorage\backups"

# Create backup directory if not exists
if (-not (Test-Path $backup_dir)) {
    New-Item -ItemType Directory -Path $backup_dir | Out-Null
}

# Create backup with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup_path = Join-Path $backup_dir "storage_$timestamp.json"

# Backup existing file
if (Test-Path $storage_json_path) {
    Copy-Item $storage_json_path $backup_path
    Write-Host "Backup created: $backup_path"
}

# Update storage.json
if (Test-Path $storage_json_path) {
    $content = Get-Content $storage_json_path -Raw | ConvertFrom-Json
} else {
    $content = @{}
}

# Update all IDs
$content.'telemetry.machineId' = $new_machine_id
$content.'telemetry.devDeviceId' = $new_dev_device_id
$content.'telemetry.macMachineId' = $new_mac_machine_id
$content.'telemetry.sqmId' = $new_sqm_id

# Save changes
$content | ConvertTo-Json -Depth 100 | Out-File $storage_json_path -Encoding UTF8

# Display results
Write-Host "Successfully updated device IDs:"
Write-Host "machineId: $new_machine_id"
Write-Host "devDeviceId: $new_dev_device_id"
Write-Host "macMachineId: $new_mac_machine_id"
Write-Host "sqmId: $new_sqm_id"