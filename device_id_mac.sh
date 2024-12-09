#!/bin/bash

# 设置严格模式
set -euo pipefail

# 配置
readonly STORAGE_FILE="$HOME/Library/Application Support/Cursor/User/globalStorage/storage.json"
readonly BACKUP_DIR="$(dirname "$STORAGE_FILE")/backups"
readonly LOG_FILE="$(dirname "$STORAGE_FILE")/update.log"

# 日志函数
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# 错误处理
error() {
    log "错误: $1"
    exit 1
}

# 使用说明
usage() {
    cat << EOF
使用方法: $(basename "$0") [选项]
选项:
    -h, --help          显示帮助信息
    -i, --id <ID>       指定新的 machineId
    -r, --restore       还原最近的备份
    -s, --show          显示当前 machineId
EOF
    exit 0
}

# 生成随机 ID
generate_random_id() {
    openssl rand -hex 32 || error "生成随机 ID 失败"
}

# 验证 ID 格式
validate_id() {
    local id=$1
    if [[ ! $id =~ ^[0-9a-f]{64}$ ]]; then
        error "无效的 ID 格式。ID 必须是 64 位十六进制字符"
    fi
}

# 创建备份
backup_file() {
    if [[ -f "$STORAGE_FILE" ]]; then
        mkdir -p "$BACKUP_DIR"
        local backup_file="$BACKUP_DIR/storage_$(date +%Y%m%d_%H%M%S).json"
        cp "$STORAGE_FILE" "$backup_file" || error "创建备份失败"
        chmod 600 "$backup_file"
        log "已创建备份文件: $backup_file"
    fi
}

# 还原最近的备份
restore_backup() {
    local latest_backup=$(ls -t "$BACKUP_DIR"/*.json 2>/dev/null | head -1)
    if [[ -n "$latest_backup" ]]; then
        cp "$latest_backup" "$STORAGE_FILE" || error "还原备份失败"
        log "已还原备份: $latest_backup"
    else
        error "没有找到可用的备份文件"
    fi
}

# 显示当前 ID
show_current_id() {
    if [[ -f "$STORAGE_FILE" ]]; then
        local current_id=$(grep -o '"telemetry\.machineId":\s*"[^"]*"' "$STORAGE_FILE" | cut -d'"' -f4)
        echo "当前 machineId: $current_id"
    else
        error "存储文件不存在"
    fi
}

# 更新 ID
update_id() {
    local new_id=$1
    validate_id "$new_id"
    
    # 确保目录存在
    mkdir -p "$(dirname "$STORAGE_FILE")"
    
    # 如果文件不存在，创建新的 JSON
    if [[ ! -f "$STORAGE_FILE" ]]; then
        echo '{"telemetry.machineId": "'$new_id'"}' > "$STORAGE_FILE"
    else
        # 创建备份
        backup_file
        
        # 更新 machineId
        sed -i.tmp 's/"telemetry\.machineId":\s*"[^"]*"/"telemetry.machineId": "'$new_id'"/' "$STORAGE_FILE" || error "更新 ID 失败"
        rm -f "${STORAGE_FILE}.tmp"
    fi
    
    chmod 600 "$STORAGE_FILE"
    log "已成功修改 machineId 为: $new_id"
}

# 主程序
main() {
    # 参数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -i|--id)
                NEW_ID="$2"
                shift 2
                ;;
            -r|--restore)
                restore_backup
                exit 0
                ;;
            -s|--show)
                show_current_id
                exit 0
                ;;
            *)
                error "未知参数: $1"
                ;;
        esac
    done

    # 如果没有指定 ID，则生成随机 ID
    NEW_ID=${NEW_ID:-$(generate_random_id)}
    update_id "$NEW_ID"
}

# 执行主程序
main "$@"