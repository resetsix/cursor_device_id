# 设置错误操作首选项
$ErrorActionPreference = "Stop"

# 设置配置文件路径
$STORAGE_FILE = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

Write-Host "开始执行脚本..."
Write-Host "目标文件路径: $STORAGE_FILE"

try {
    # 生成随机ID
    $NEW_MACHINE_ID = -join ((1..32) | ForEach-Object { "{0:x2}" -f (Get-Random -Max 256) })
    $NEW_MAC_MACHINE_ID = -join ((1..32) | ForEach-Object { "{0:x2}" -f (Get-Random -Max 256) })
    $NEW_SQM_ID = "{" + [guid]::NewGuid().ToString().ToUpper() + "}"
    $NEW_DEV_DEVICE_ID = [guid]::NewGuid().ToString()

    # 创建备份
    if (Test-Path $STORAGE_FILE) {
        $backupName = "$STORAGE_FILE.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $STORAGE_FILE $backupName
    }

    # 读取并更新JSON内容
    $json = Get-Content $STORAGE_FILE -Raw
    $json = $json -replace '"telemetry\.machineId"\s*:\s*"[^"]*"', "`"telemetry.machineId`": `"$NEW_MACHINE_ID`""
    $json = $json -replace '"telemetry\.macMachineId"\s*:\s*"[^"]*"', "`"telemetry.macMachineId`": `"$NEW_MAC_MACHINE_ID`""
    $json = $json -replace '"telemetry\.sqmId"\s*:\s*"[^"]*"', "`"telemetry.sqmId`": `"$NEW_SQM_ID`""
    $json = $json -replace '"telemetry\.devDeviceId"\s*:\s*"[^"]*"', "`"telemetry.devDeviceId`": `"$NEW_DEV_DEVICE_ID`""
    
    # 保存更新后的内容
    $json | Set-Content $STORAGE_FILE -NoNewline

    Write-Host "操作成功完成!"
}
catch {
    Write-Host "脚本执行错误!"
    Write-Host "错误信息: $($_.Exception.Message)"
    Write-Host "请确保Cursor编辑器已关闭且您有足够的文件访问权限。"
}

Write-Host "按任意键继续..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")