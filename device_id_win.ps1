# 定义函数来生成随机标识符
function New-RandomIdentifier {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("UUID", "HEX")]
        [string]$Type,
        
        [Parameter()]
        [int]$Length = 32
    )
    
    switch ($Type) {
        "UUID" { return [guid]::NewGuid().ToString().ToLower() }
        "HEX"  { return -join ((1..$Length) | ForEach-Object { '{0:x}' -f (Get-Random -Max 16) }) }
    }
}

# 定义文件路径
$paths = @{
    MachineId = Join-Path $env:APPDATA "Cursor\machineid"
    Storage   = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
}

# 生成新的标识符
$newIds = @{
    MachineId     = New-RandomIdentifier -Type "UUID"
    DevDeviceId   = New-RandomIdentifier -Type "UUID"
    MacMachineId  = New-RandomIdentifier -Type "HEX"
}

try {
    # 创建备份
    foreach ($path in $paths.GetEnumerator()) {
        if (Test-Path $path.Value) {
            Copy-Item -Path $path.Value -Destination "$($path.Value).backup" -Force
            Write-Host "已创建备份: $($path.Value).backup" -ForegroundColor Green
        }
    }

    # 更新 machineid 文件
    $newIds.MachineId | Out-File -FilePath $paths.MachineId -Encoding UTF8 -NoNewline -Force
    Write-Host "已更新 machineid 文件" -ForegroundColor Green

    # 更新 storage.json 文件
    if (Test-Path $paths.Storage) {
        $storageContent = Get-Content $paths.Storage -Raw | ConvertFrom-Json
        $storageContent.'telemetry.devDeviceId' = $newIds.DevDeviceId
        $storageContent.'telemetry.macMachineId' = $newIds.MacMachineId
        $storageContent | ConvertTo-Json -Depth 100 | Out-File $paths.Storage -Encoding UTF8 -Force
        Write-Host "已更新 storage.json 文件" -ForegroundColor Green
    } else {
        Write-Warning "storage.json 文件不存在"
    }
}
catch {
    Write-Error "发生错误: $_"
    # 如果出错，尝试恢复备份
    foreach ($path in $paths.GetEnumerator()) {
        $backupPath = "$($path.Value).backup"
        if (Test-Path $backupPath) {
            Copy-Item -Path $backupPath -Destination $path.Value -Force
            Write-Host "已从备份恢复: $($path.Value)" -ForegroundColor Yellow
        }
    }
    exit 1
}

Write-Host "所有操作已完成" -ForegroundColor Green