# Generate new UUID and convert to lowercase
$new_machine_id = [guid]::NewGuid().ToString().ToLower()
$new_dev_device_id = [guid]::NewGuid().ToString().ToLower()
# Generate 32-byte random hexadecimal string
$new_mac_machine_id = -join ((1..32) | ForEach-Object { "{0:x}" -f (Get-Random -Max 16) })

Write-Host "Script started - Generating new device IDs..."
Write-Host "Generated machine ID: $new_machine_id"
Write-Host "Generated device ID: $new_dev_device_id"
Write-Host "Generated MAC machine ID: $new_mac_machine_id"

# Define file paths
$machine_id_path = "$env:APPDATA\Cursor\machineid"
$storage_json_path = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

Write-Host "`nTarget file paths:"
Write-Host "Machine ID path: $machine_id_path"
Write-Host "Storage JSON path: $storage_json_path"

# Backup original files
Copy-Item $machine_id_path "$machine_id_path.backup" -ErrorAction SilentlyContinue
Copy-Item $storage_json_path "$storage_json_path.backup" -ErrorAction SilentlyContinue
Write-Host "`nBackup files created (if original files existed)"

# Update machineid file
$new_machine_id | Out-File -FilePath $machine_id_path -Encoding UTF8 -NoNewline
Write-Host "Machine ID file updated successfully"

# Read and update storage.json file
$content = Get-Content $storage_json_path -Raw | ConvertFrom-Json
$content.'telemetry.devDeviceId' = $new_dev_device_id
$content.'telemetry.macMachineId' = $new_mac_machine_id

# Save updated storage.json file
$content | ConvertTo-Json -Depth 100 | Out-File $storage_json_path -Encoding UTF8
Write-Host "Storage JSON file updated successfully"

Write-Host "`nScript completed - All device IDs have been updated"