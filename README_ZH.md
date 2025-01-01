# Cursor 设备标识管理工具

[English](README.md) | 简体中文

## 问题背景

使用 Cursor 试用多个Pro账户后，遇到`Too many free trial accounts used on this machine`限制。

## 项目简介

Cursor 设备标识管理工具是一个用于管理和修改 Cursor 编辑器设备标识(Device ID)的命令行工具。解决以上设备限制问题，通过重置设备标识来恢复正常使用。

## 系统要求

### Windows

- `PowerShell`
- 管理员权限

### macOS

- `bash` or `zsh` shell
- 用户目录写入权限

## 使用指南

使用前请确保：

1. 已完全关闭 Cursor 编辑器

### Windows 使用方式

1. 在线运行（推荐）：

```powershell
# 以管理员身份运行 PowerShell 并执行:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process; iwr -useb https://raw.githubusercontent.com/resetsix/cursor_device_id/main/device_id_win.ps1 | iex
```

2. 手动下载运行：

   ```powershell
   # 方式1：右键脚本 -> "以管理员身份运行 PowerShell"

   # 方式2：管理员 PowerShell 中执行
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\device_id_win.ps1
   ```

注意：执行完成后如无任何错误提示，则表示更新成功。

### macOS 使用方式

1. 运行，自动生成所有ID：

```bash
curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash
```

2. 可用选项：

   a. 显示帮助:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --help
   ```

   b. 使用自动生成的ID更新:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash
   ```

   c. 指定ID更新:
   ```bash
   # 更新 machineId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -m <machine-id>
   
   # 更新 devDeviceId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -d <dev-id>
   
   # 更新 macMachineId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -c <mac-id>
   
   # 更新 sqmId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -s <sqm-id>
   
   # 同时更新多个ID
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -m <machine-id> -d <dev-id> -c <mac-id> -s <sqm-id>
   ```

   d. 显示当前ID:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --show
   ```

   e. 还原备份:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --restore
   ```

3. 日志查看：
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
