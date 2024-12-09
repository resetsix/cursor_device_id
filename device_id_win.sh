Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:LogFile = Join-Path $env:TEMP "CursorReset_$(Get-Date -Format 'yyyyMMdd').log"
$script:MaxBackupCount = 5

function New-RandomHexString {
    param (
        [int]$Length = 64
    )
    -join ((48..57) + (97..102) | Get-Random -Count $Length | ForEach-Object {[char]$_})
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')|$Level|$Message"
    Add-Content -Path $script:LogFile -Value $logMessage
    
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARN"  { Write-Host $Message -ForegroundColor Yellow }
        "INFO"  { Write-Host $Message -ForegroundColor Green }
    }
}

function Backup-JsonFile {
    param (
        [string]$Path
    )
    try {
        $backups = Get-ChildItem -Path (Split-Path $Path) -Filter "*.backup_*" | Sort-Object LastWriteTime -Descending
        if ($backups.Count -ge $script:MaxBackupCount) {
            $backups | Select-Object -Skip ($script:MaxBackupCount - 1) | Remove-Item -Force
        }
        
        $backupPath = "$Path.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item -Path $Path -Destination $backupPath
        Write-Log "已创建备份文件: $backupPath"
        return $true
    }
    catch {
        Write-Log "备份文件失败: $_" -Level "ERROR"
        return $false
    }
}

function Test-CursorProcess {
    $cursorProcess = Get-Process -Name "Cursor" -ErrorAction SilentlyContinue
    if ($cursorProcess) {
        throw "请先关闭Cursor应用程序再继续操作"
    }
}

function Reset-CursorIds {
    try {
        Write-Log "开始重置Cursor ID..." -Level "INFO"
        
        # 检查Cursor是否运行
        Test-CursorProcess
        
        $cursor_path = Join-Path $env:APPDATA "Cursor"
        $storage_path = Join-Path $cursor_path "User\globalStorage\storage.json"
        
        if (-not (Test-Path $storage_path)) {
            throw "找不到storage.json文件: $storage_path"
        }
        
        $file = Get-Item $storage_path
        if ($file.IsReadOnly) {
            $file.IsReadOnly = $false
            Write-Log "已移除文件只读属性" -Level "INFO"
        }
        
        if (-not (Backup-JsonFile -Path $storage_path)) {
            throw "备份文件失败,操作已中止"
        }

        $new_machine_id = [guid]::NewGuid().ToString().ToLower()
        $new_dev_device_id = [guid]::NewGuid().ToString().ToLower()
        $new_mac_machine_id = New-RandomHexString

        $machine_id_path = Join-Path $cursor_path "machineid"
        $new_machine_id | Out-File -FilePath $machine_id_path -Encoding utf8 -NoNewline -Force
        Write-Host "已更新machineid文件" -ForegroundColor Green

        $json_content = Get-Content -Path $storage_path -Raw | ConvertFrom-Json
        
        $json_content.'telemetry.devDeviceId' = $new_dev_device_id
        $json_content.'telemetry.macMachineId' = $new_mac_machine_id
        $json_content.'telemetry.machineId' = $new_machine_id

        $json_content | ConvertTo-Json -Depth 100 | Set-Content -Path $storage_path -Encoding utf8 -Force
        Write-Host "已成功更新storage.json文件" -ForegroundColor Green

        $updated_content = Get-Content -Path $storage_path -Raw | ConvertFrom-Json
        if ($updated_content.'telemetry.machineId' -ne $new_machine_id) {
            throw "文件更新验证失败"
        }

        Write-Log "所有操作已完成" -Level "INFO"
        return $true
    }
    catch {
        Write-Log "发生错误: $_" -Level "ERROR"
        $latest_backup = Get-ChildItem -Path (Split-Path $storage_path) -Filter "*.backup_*" | 
                        Sort-Object LastWriteTime -Descending | 
                        Select-Object -First 1
        if ($latest_backup) {
            Copy-Item -Path $latest_backup.FullName -Destination $storage_path -Force
            Write-Log "已恢复到最新备份" -Level "WARN"
        }
        return $false
    }
}

# 主执行逻辑
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "请以管理员权限运行此脚本" -ForegroundColor Red
    exit
}

Reset-CursorIds