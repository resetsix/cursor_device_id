#!/bin/bash

# Strict mode
set -euo pipefail

# Config
readonly STORAGE_FILE="$HOME/Library/Application Support/Cursor/User/globalStorage/storage.json"
readonly BACKUP_DIR="$(dirname "$STORAGE_FILE")/backups"
readonly LOG_FILE="$(dirname "$STORAGE_FILE")/update.log"

# Logger
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handler
error() {
    log "Error: $1"
    exit 1
}

# Check if Cursor is running
check_cursor() {
    if pgrep -f "/Applications/Cursor.app/Contents/MacOS/Cursor" > /dev/null; then
        error "Please close Cursor application before running this script"
    fi
    
    if pgrep -f "Cursor Helper" > /dev/null; then
        pkill -f "Cursor Helper"
    fi
}

# Help
usage() {
    cat << EOF
Usage: $(basename "$0") [options]
Options:
    -h, --help          Show help
    -m, --machine-id    Set machineId (64-bit hex)
    -d, --dev-id       Set devDeviceId (UUID)
    -c, --mac-id       Set macMachineId (UUID)
    -s, --sqm-id       Set sqmId (UUID)
    -r, --restore      Restore backup
    --show             Show current IDs
EOF
    exit 0
}

# Generate IDs
generate_machine_id() {
    openssl rand -hex 32 || error "Failed to generate machineId"
}

generate_uuid() {
    uuidgen | tr '[:upper:]' '[:lower:]' || error "Failed to generate UUID"
}

generate_sqm_id() {
    echo "{$(uuidgen)}" || error "Failed to generate SQM ID"
}

# Validate IDs
validate_machine_id() {
    [[ $1 =~ ^[0-9a-f]{64}$ ]] || error "Invalid machineId format"
}

validate_uuid() {
    [[ $1 =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || error "Invalid UUID format"
}

validate_sqm_id() {
    [[ $1 =~ ^\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}$ ]] || error "Invalid SQM ID format"
}

# Backup management
backup_file() {
    if [[ -f "$STORAGE_FILE" ]]; then
        mkdir -p "$BACKUP_DIR"
        local backup_file="$BACKUP_DIR/storage_$(date +%Y%m%d_%H%M%S).json"
        cp "$STORAGE_FILE" "$backup_file" || error "Backup failed"
        chmod 600 "$backup_file"
        log "Backup created: $backup_file"
    fi
}

restore_backup() {
    local latest_backup=$(ls -t "$BACKUP_DIR"/*.json 2>/dev/null | head -1)
    if [[ -n "$latest_backup" ]]; then
        cp "$latest_backup" "$STORAGE_FILE" || error "Restore failed"
        log "Restored: $latest_backup"
    else
        error "No backup found"
    fi
}

# Display IDs
show_current_ids() {
    if [[ -f "$STORAGE_FILE" ]]; then
        echo "Current IDs:"
        echo "machineId: $(grep -o '"telemetry\.machineId":\s*"[^"]*"' "$STORAGE_FILE" | cut -d'"' -f4)"
        echo "devDeviceId: $(grep -o '"telemetry\.devDeviceId":\s*"[^"]*"' "$STORAGE_FILE" | cut -d'"' -f4)"
        echo "macMachineId: $(grep -o '"telemetry\.macMachineId":\s*"[^"]*"' "$STORAGE_FILE" | cut -d'"' -f4)"
        echo "sqmId: $(grep -o '"telemetry\.sqmId":\s*"[^"]*"' "$STORAGE_FILE" | cut -d'"' -f4)"
    else
        error "Storage file not found"
    fi
}

# Update ID
update_id() {
    local key=$1
    local value=$2
    local temp_file="${STORAGE_FILE}.tmp"
    
    # Create temp file with new content
    if [[ -f "$STORAGE_FILE" ]]; then
        # Read entire file content
        local content
        content=$(cat "$STORAGE_FILE")
        
        # Create new content with updated value
        local new_content
        new_content=$(echo "$content" | perl -pe 's/"'$key'":\s*"[^"]*"/"'$key'": "'$value'"/g')
        
        # Write to temp file
        echo "$new_content" > "$temp_file"
    else
        echo '{"'$key'": "'$value'"}' > "$temp_file"
    fi
    
    # Move temp file to original
    mv "$temp_file" "$STORAGE_FILE"
    
    # Set permissions
    chmod 600 "$STORAGE_FILE"
    
    # Force write to disk
    sync
    
    # Verify the change
    if ! grep -q "\"$key\": \"$value\"" "$STORAGE_FILE"; then
        error "Failed to update $key"
    fi
    
    log "Updated $key: $value"
}

# Main
main() {
    local MACHINE_ID=""
    local DEV_ID=""
    local MAC_ID=""
    local SQM_ID=""

    # Check if Cursor is running
    check_cursor

    # Parse args
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage ;;
            -m|--machine-id) MACHINE_ID="$2"; shift 2 ;;
            -d|--dev-id) DEV_ID="$2"; shift 2 ;;
            -c|--mac-id) MAC_ID="$2"; shift 2 ;;
            -s|--sqm-id) SQM_ID="$2"; shift 2 ;;
            -r|--restore) restore_backup; exit 0 ;;
            --show) show_current_ids; exit 0 ;;
            *) error "Unknown option: $1" ;;
        esac
    done

    # Create backup
    backup_file

    # Update IDs
    if [[ -z "$MACHINE_ID" ]]; then
        MACHINE_ID=$(generate_machine_id)
    fi
    validate_machine_id "$MACHINE_ID"
    update_id "telemetry.machineId" "$MACHINE_ID"

    if [[ -z "$DEV_ID" ]]; then
        DEV_ID=$(generate_uuid)
    fi
    validate_uuid "$DEV_ID"
    update_id "telemetry.devDeviceId" "$DEV_ID"

    if [[ -z "$MAC_ID" ]]; then
        MAC_ID=$(generate_uuid)
    fi
    validate_uuid "$MAC_ID"
    update_id "telemetry.macMachineId" "$MAC_ID"

    if [[ -z "$SQM_ID" ]]; then
        SQM_ID=$(generate_sqm_id)
    fi
    validate_sqm_id "$SQM_ID"
    update_id "telemetry.sqmId" "$SQM_ID"

    # Force write to disk
    sync

    log "All IDs updated"
    show_current_ids
}

main "$@"