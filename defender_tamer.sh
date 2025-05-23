#!/bin/bash

LOG_FILE="/tmp/defender_tamer.log"

# Log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Clean log if older than 1 hour
if [ -f "$LOG_FILE" ]; then
    if find "$LOG_FILE" -mmin +60 | grep -q .; then
        : > "$LOG_FILE"
        log "Log file cleaned (older than 1 hour)"
    fi
fi

# Check if running on battery
on_battery=$(ioreg -n AppleSmartBattery | grep -i '"ExternalConnected" = No')

# Processes to manage (name|description)
processes=(
    "wdav|Main Defender antivirus engine process"
    "wdavdaemon|Daemon for Defender background services"
    "wdavdaemon_enterprise|Enterprise Defender engine"
    "Microsoft Defender Helper|UI support process"
    "netext|Network extension for traffic scanning"
    "telemetryd|Telemetry and diagnostic data uploader"
    "mdatp|Defender ATP core agent"
    "mdatpaux|Auxiliary background service"
    "mdatpscan|File scanning service"
    "mdatplogd|Logging daemon for Defender events"
    "mdatpdiagnostic|System health diagnostic service"
    "epsext|System extension for endpoint protection scanning"
)

# Process info log
get_process_info() {
    local pid=$1
    ps -p "$pid" -o pid,ni,comm,args= | tail -n +2
}

# Apply low priority and background
tame_process() {
    local pname="$1"
    local description="$2"

    for pid in $(pgrep -f "$pname"); do
        current_nice=$(ps -o ni= -p "$pid" | xargs)
        if [ "$current_nice" -lt 20 ]; then
            sudo renice +20 -p "$pid" >/dev/null 2>&1
            sudo taskpolicy -b -p "$pid" >/dev/null 2>&1
            info=$(get_process_info "$pid")
            log "Tamed $pname (PID $pid), background=yes – $description"
            log "  └─ $info"
        fi
    done
}

# Restore to normal priority
untame_process() {
    local pname="$1"
    local description="$2"

    for pid in $(pgrep -f "$pname"); do
        current_nice=$(ps -o ni= -p "$pid" | xargs)
        if [ "$current_nice" -gt 0 ]; then
            sudo renice 0 -p "$pid" >/dev/null 2>&1
            sudo taskpolicy -p "$pid" >/dev/null 2>&1
            info=$(get_process_info "$pid")
            log "Restored $pname (PID $pid) to normal priority – $description"
            log "  └─ $info"
        fi
    done
}

# Main logic
if [ -n "$on_battery" ]; then
    log "On battery – applying low-priority to Defender processes"
    for entry in "${processes[@]}"; do
        pname="${entry%%|*}"
        description="${entry##*|}"
        tame_process "$pname" "$description"
    done
else
    log "On AC power – restoring Defender process priorities"
    for entry in "${processes[@]}"; do
        pname="${entry%%|*}"
        description="${entry##*|}"
        untame_process "$pname" "$description"
    done
fi