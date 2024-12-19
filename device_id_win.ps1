$new_machine_id = [guid]::NewGuid().ToString().ToLower()
$new_dev_device_id = [guid]::NewGuid().ToString().ToLower()

$new_mac_machine_id = -join ((1..32) | ForEach-Object { "{0:x}" -f (Get-Random -Max 16) })

$machine_id_path = "$env:APPDATA\Cursor\machineid"
$storage_json_path = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

Copy-Item $machine_id_path "$machine_id_path.backup" -ErrorAction SilentlyContinue
Copy-Item $storage_json_path "$storage_json_path.backup" -ErrorAction SilentlyContinue

$new_machine_id | Out-File -FilePath $machine_id_path -Encoding UTF8 -NoNewline

$content = Get-Content $storage_json_path -Raw | ConvertFrom-Json
$content.'telemetry.devDeviceId' = $new_dev_device_id
$content.'telemetry.macMachineId' = $new_mac_machine_id

$content | ConvertTo-Json -Depth 100 | Out-File $storage_json_path -Encoding UTF8