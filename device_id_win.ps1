# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "请以管理员权限运行此脚本"
    exit 1
}

# 定义日志文件路径
$logFile = "$env:TEMP\cursor_device_id_update.log"

# 添加日志函数
function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $Message
}

try {
    Write-Log "开始执行设备ID更新..."
    
    # 生成新的标识符
    $new_cursor_device_id = [guid]::NewGuid().ToString().ToLower()
    Write-Log "生成新的cursor_device_id: $new_cursor_device_id"
    
    $new_dev_device_id = [guid]::NewGuid().ToString().ToLower()
    $new_mac_cursor_device_id = -join ((1..32) | ForEach-Object { "{0:x}" -f (Get-Random -Max 16) })

    # 定义文件路径
    $cursor_device_id_path = "$env:APPDATA\Cursor\machineid"
    $storage_json_path = "$env:APPDATA\Cursor\User\globalStorage\storage.json"

    # 检查文件是否存在
    if (-not (Test-Path $cursor_device_id_path) -or -not (Test-Path $storage_json_path)) {
        Write-Error "未找到必要的Cursor配置文件"
        exit 1
    }

    # 创建带时间戳的备份
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $cursor_device_id_path "$cursor_device_id_path.backup_$timestamp" -ErrorAction Stop
    Copy-Item $storage_json_path "$storage_json_path.backup_$timestamp" -ErrorAction Stop
    Write-Log "已创建配置文件备份"

    # 更新 machineid 文件
    $new_cursor_device_id | Out-File -FilePath $cursor_device_id_path -Encoding UTF8 -NoNewline
    Write-Log "已更新 machineid"

    # 读取并更新 storage.json 文件
    $content = Get-Content $storage_json_path -Raw | ConvertFrom-Json
    $content.'telemetry.devDeviceId' = $new_dev_device_id
    $content.'telemetry.macMachineId' = $new_mac_cursor_device_id

    # 保存更新后的 storage.json 文件
    $content | ConvertTo-Json -Depth 100 | Out-File $storage_json_path -Encoding UTF8
    Write-Log "已更新 storage.json"

    Write-Log "所有操作已完成"
}
catch {
    Write-Log "执行过程中发生错误: $_"
    exit 1
}