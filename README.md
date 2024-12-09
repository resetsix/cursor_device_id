# Cursor 设备标识管理工具

## 问题背景

使用 Cursor 试用多次Pro账户后，遇到`Too many free trial accounts used on this machine`限制。

## 项目简介

Cursor 设备标识管理工具是一个用于管理和修改 Cursor 编辑器设备标识(Device ID)的命令行工具。解决以上设备限制问题，通过重置设备标识来恢复正常使用。

## 技术原理

本工具通过修改 Cursor 编辑器的配置文件来更新设备标识。主要步骤包括：

1. 自动定位配置文件
2. 生成新的设备标识
3. 创建配置备份
4. 安全地更新配置

## 主要特性

- 📝 自动生成随机设备标识
- 🔒 配置文件自动备份机制
- ⚙️ 支持自定义设备标识
- 🛠 使用系统原生工具，无额外依赖
- 💻 命令行界面
- 📋 详细操作日志

## 系统要求

- 操作系统：macOS
- 权限：用户目录写入权限
- 依赖：系统内置的 bash、openssl

## 使用指南

### 基本用法

```sh
# 显示帮助信息
./cursor_device_id_manager.sh --help

# 使用随机生成的 ID 更新
./cursor_device_id_manager.sh

# 指定 ID 更新
./cursor_device_id_manager.sh --id <your-id>

# 显示当前 ID
./cursor_device_id_manager.sh --show

# 还原最近的备份
./cursor_device_id_manager.sh --restore
```

### 配置文件位置

默认配置文件路径：
```
~/Library/Application Support/Cursor/storage.json
```

### 备份说明

- 位置：与原配置文件相同目录
- 命名格式：`storage.json.backup_YYYYMMDD_HHMMSS`
- 每次修改前自动创建

## 使用场景

1. 解除设备锁定
2. 重置配置

## 最佳实践

1. 修改前：
   - 关闭 Cursor 编辑器
   - 保存重要数据
2. 修改后：
   - 验证配置更新
   - 检查备份完整性

## 安全建议

- 遵守软件使用条款
