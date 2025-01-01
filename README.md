# Cursor Device ID Management Tool

Language: English | [简体中文](README_ZH.md)

## Background

After trying multiple Pro accounts with Cursor, users may encounter the `Too many free trial accounts used on this machine` restriction.

## Project Overview

The Cursor Device ID Management Tool is a command-line utility for managing and modifying the Cursor editor's device identification (`Device ID`). It resolves the above device restriction issue by resetting the device identifier to restore normal usage.

## System Requirements

### Windows

- `PowerShell`
- Administrator privileges

### macOS

- `bash` or `zsh` shell
- User directory write permissions

## Usage Guide

Before using, please ensure:

1. Cursor editor is completely closed

### Windows Usage

1. Online execution (recommended):

```powershell
# Run PowerShell as Administrator and execute:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process; iwr -useb https://raw.githubusercontent.com/resetsix/cursor_device_id/main/device_id_win.ps1 | iex
```

2. Manual download and run:

   ```powershell
   # Option 1: Right-click script -> "Run PowerShell as Administrator"

   # Option 2: Execute in Administrator PowerShell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\device_id_win.ps1
   ```

Note: If no error messages appear after execution, the update was successful.

### macOS Usage

1. Run with auto-generated IDs:

```bash
curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash
```

2. Available options:

   a. Show help:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --help
   ```

   b. Update with auto-generated IDs:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash
   ```

   c. Update with specific IDs:
   ```bash
   # Update machineId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -m <machine-id>
   
   # Update devDeviceId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -d <dev-id>
   
   # Update macMachineId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -c <mac-id>
   
   # Update sqmId
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -s <sqm-id>
   
   # Update multiple IDs
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- -m <machine-id> -d <dev-id> -c <mac-id> -s <sqm-id>
   ```

   d. Show current IDs:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/resetsix/cursor_device_id/refs/heads/main/device_id_mac.sh | bash -s -- --show
   ```

   e. Restore backup:
   ```bash
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
