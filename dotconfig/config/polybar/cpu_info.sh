#!/usr/bin/env bash
set -Eeuo pipefail

read_cpu_stat() {
    head -1 /proc/stat | awk '{print $2, $3, $4, $5, $6, $7, $8}'
}

get_usage() {
    read -r user1 nice1 system1 idle1 iowait1 irq1 softirq1 <<< "$(read_cpu_stat)"
    total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1))
    idle_all1=$((idle1 + iowait1))

    sleep 0.3

    read -r user2 nice2 system2 idle2 iowait2 irq2 softirq2 <<< "$(read_cpu_stat)"
    total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2))
    idle_all2=$((idle2 + iowait2))

    total_diff=$((total2 - total1))
    idle_diff=$((idle_all2 - idle_all1))

    if [ "$total_diff" -eq 0 ]; then
        printf "N/A"
    else
        printf "%d%%" "$(( (100 * (total_diff - idle_diff)) / total_diff ))"
    fi
}

get_temp() {
    local hwmon name label input temp
    for hwmon in /sys/class/hwmon/hwmon*; do
        [ -f "$hwmon/name" ] || continue
        name="$(cat "$hwmon/name")"
        case "$name" in
            coretemp|k10temp|zenpower)
                ;;
            *)
                continue
                ;;
        esac

        for input in "$hwmon"/temp*_input; do
            label=$(cat "${input%_input}_label")
            if [[ "$label" == "Package id 0" || "$label" == "Tctl" ]]; then
                temp="$(cat "$input")"
                printf "%.1f" "$((temp / 1000))"
                return
            fi
        done

        if [ -f "${hwmon}/temp1_input" ]; then
            temp="$(cat "$hwmon/temp1_input")"
            printf "%.1f" "$((temp / 1000))"
            return
        fi
    done
    printf "N/A"
}

echo "CPU $(get_usage) $(get_temp)"

