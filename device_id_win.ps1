# Generate new UUID and convert to lowercase
$new_device_id = [guid]::NewGuid().ToString().ToLower()
$new_dev_device_id = [guid]::NewGuid().ToString().ToLower()
# Generate 32-byte random hexadecimal string
$new_mac_device_id = -join ((1..32) | ForEach-Object { "{0:x}" -f (Get-Random -Max 16) })

Write-Host "new ID:" -ForegroundColor Yellow
Write-Host "device_id: $new_device_id" -ForegroundColor Green
Write-Host "dev_device_id: $new_dev_device_id" -ForegroundColor Green 
Write-Host "mac_device_id: $new_mac_device_id" -ForegroundColor Green

# Define file paths
$device_id_path = "$env:APPDATA\Cursor\deviceid"
$storage_json_path = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

Write-Host "`n文件路径:" -ForegroundColor Yellow
Write-Host "deviceid路径: $device_id_path" -ForegroundColor Green
Write-Host "storage.json路径: $storage_json_path" -ForegroundColor Green

# Backup original files
Write-Host "`n开始备份文件..." -ForegroundColor Yellow
Copy-Item $device_id_path "$device_id_path.backup" -ErrorAction SilentlyContinue
Copy-Item $storage_json_path "$storage_json_path.backup" -ErrorAction SilentlyContinue
Write-Host "文件备份完成" -ForegroundColor Green

# Update deviceid file
Write-Host "`n更新deviceid文件..." -ForegroundColor Yellow
$new_device_id | Out-File -FilePath $device_id_path -Encoding UTF8 -NoNewline
Write-Host "deviceid更新完成" -ForegroundColor Green

# Read and update storage.json file
Write-Host "`n更新storage.json..." -ForegroundColor Yellow
$content = Get-Content $storage_json_path -Raw | ConvertFrom-Json
$content.'telemetry.devDeviceId' = $new_dev_device_id
$content.'telemetry.macdeviceId' = $new_mac_device_id

# Save updated storage.json file
$content | ConvertTo-Json -Depth 100 | Out-File $storage_json_path -Encoding UTF8
Write-Host "storage.json更新完成" -ForegroundColor Green