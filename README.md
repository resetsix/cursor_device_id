# Cursor 设备标识管理工具

## 问题背景

使用 Cursor 试用多次Pro账户后，遇到`Too many free trial accounts used on this machine`限制。

## 项目简介

Cursor 设备标识管理工具是一个用于管理和修改 Cursor 编辑器设备标识(Device ID)的命令行工具。解决以上设备限制问题，通过重置设备标识来恢复正常使用。

## 系统要求

### Windows
- Windows 10/11
- PowerShell 5.0+
- 管理员权限

### macOS
- macOS 10.13+
- bash shell
- 用户目录写入权限

## 使用指南

⚠️ 使用前请确保：
1. 已完全关闭 Cursor 编辑器

### Windows 使用方式

1. 下载 `device_id_win` 脚本

2. 运行方式（二选一）：
   ```powershell
   # 方式1：右键脚本 -> "以管理员身份运行 PowerShell"

   # 方式2：管理员 PowerShell 中执行
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\device_id_win.ps1
   ```

3. 日志查看：
   - 位置：`%TEMP%\CursorReset_当前日期.log`

### macOS 使用方式

1. 下载 `device_id_mac.sh` 脚本

2. 添加执行权限：
   ```bash
   chmod +x device_id_mac.sh
   ```

3. 运行选项：
   ```bash
   # 显示帮助
   ./device_id_mac.sh --help

   # 使用随机ID更新
   ./device_id_mac.sh

   # 指定ID更新
   ./device_id_mac.sh --id <your-id>

   # 显示当前ID
   ./device_id_mac.sh --show

   # 还原备份
   ./device_id_mac.sh --restore
   ```

4. 日志查看：
   - 位置：`~/Library/Application Support/Cursor/User/globalStorage/update.log`

## 配置文件位置

### Windows
```
%APPDATA%\Cursor\User\globalStorage\storage.json
```

### macOS
```
~/Library/Application Support/Cursor/User/globalStorage/storage.json
```

## 备份说明

### Windows
- 位置：与配置文件相同目录
- 格式：`storage.json.backup_YYYYMMDD_HHMMSS`
- 保留最近5个备份

### macOS
- 位置：配置文件目录下的 `backups` 文件夹
- 格式：`storage_YYYYMMDD_HHMMSS.json`

## 常见问题

### Windows
1. "无法加载脚本"错误
   - 以管理员身份运行 PowerShell
   - 执行 `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`

2. "拒绝访问"错误
   - 确保以管理员身份运行
   - 检查文件权限

### macOS
1. "权限拒绝"错误
   - 检查脚本执行权限
   - 确认用户目录权限

2. "命令未找到"错误
   - 确保在脚本所在目录执行
   - 检查文件名大小写