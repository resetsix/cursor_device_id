# Cursor Device ID Management Tool

Language: [简体中文](README_ZH.md) | English

## Background

After trying multiple Pro accounts with Cursor, users may encounter the `Too many free trial accounts used on this machine` restriction.

## Project Overview

The Cursor Device ID Management Tool is a command-line utility for managing and modifying the Cursor editor's device identification (`Device ID`). It resolves the above device restriction issue by resetting the device identifier to restore normal usage.

## System Requirements

### Windows

- `CMD` or `PowerShell`
- Administrator privileges

### macOS

- `bash` or `zsh` shell
- User directory write permissions

## Usage Guide

Before using, please ensure:

1. Cursor editor is completely closed

### Windows Usage

1. Download `device_id_win.ps1` script

2. Run options (choose one):

   ```powershell
   # Option 1: Right-click script -> "Run PowerShell as Administrator"

   # Option 2: Execute in Administrator PowerShell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\device_id_win.ps1
   ```

3. View logs:
   - Location: `$env:TEMP\cursor_device_id_update.log`

### macOS Usage

1. Run with random ID update:

```bash
curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash
```

2. Run options:

   ```bash
   # Show help
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --help

   # Update with random ID
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash

   # Update with specific ID
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --id <your-id>

   # Show current ID
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --show

   # Restore backup
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --restore
   ```

3. View logs:
   - Location: `~/Library/Application Support/Cursor/User/globalStorage/update.log`

## Configuration File Location

### Windows

```
%APPDATA%\Cursor\User\globalStorage\storage.json
```

### macOS

```
~/Library/Application Support/Cursor/User/globalStorage/storage.json
```

## Backup Information

### Windows

- Location: Same directory as configuration file
- Format: `storage.json.backup_YYYYMMDD_HHMMSS`
- Keeps the 5 most recent backups

### macOS

- Location: `backups` folder in the configuration file directory
- Format: `storage_YYYYMMDD_HHMMSS.json`

## Common Issues

### Windows

1. "`Cannot load script`" error

   - Run `PowerShell` as Administrator
   - Execute `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`

2. "`Access denied`" error
   - Ensure running as Administrator
   - Check file permissions

### macOS

1. "`Permission denied`" error

   - Check script execution permissions
   - Verify user directory permissions

2. "`Command not found`" error
   - Ensure executing from script directory
   - Check file name case sensitivity
