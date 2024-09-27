#!/usr/bin/env bash

# Source color vars
source "$HOME/.local/share/statusbar/colorvars.sh"

# Define Basic Dimentions
base_x=0
base_y=2
max_height=15
bar_width=3
gap=1

cpu() {
    local cpu_line1=$(grep '^cpu ' /proc/stat)
    sleep 2
    local cpu_line2=$(grep '^cpu ' /proc/stat)
    local -a cpu1=(${cpu_line1//cpu/})
    local -a cpu2=(${cpu_line2//cpu/})
    local total1=0
    local total2=0
    local idle1=${cpu1[3]}
    local idle2=${cpu2[3]}
    for i in "${cpu1[@]}"; do
        total1=$((total1 + i))
    done
    for i in "${cpu2[@]}"; do
        total2=$((total2 + i))
    done
    local total_delta=$((total2 - total1))
    local idle_delta=$((idle2 - idle1))

    local usage=$((100 * (total_delta - idle_delta) / total_delta))

    local usage_height=$(( (max_height * usage) / 100 ))
    local usage_y=$((base_y + max_height - usage_height))
    local color=$white
    if [ $usage -gt 50 ]; then
        color=$red
    fi
    local status_line=""
    status_line+="^c${grey}^^r${base_x},${base_y},${bar_width},${max_height}^"
    status_line+="^c${color}^^r${base_x},${usage_y},${bar_width},${usage_height}^"
    status_line+="^d^^f4^" # buffer of 1
#   local topcon=$( ps -eo %cpu,comm --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print $2}')
#	topcon="${topcon:0:5}" # trunkate output
    echo "{CPU:${status_line}${usage}%"
}

ram() {
    local m_mem=$(free -m)
    local t_mem=$(echo "$m_mem" | awk '/^Mem:/ {print $2}')
    local u_mem=$(echo "$m_mem" | awk '/^Mem:/ {print $3}')
    local p_mem=$(awk "BEGIN {printf \"%.0f\", ($u_mem/$t_mem)*100}")
    local usage_height=$((max_height * p_mem / 100))
    local usage_y=$((base_y + max_height - usage_height))
    local status_line=""
    status_line+="^c$grey^^r$base_x,${base_y},${bar_width},${max_height}^"
    status_line+="^c$white^^r${base_x},${usage_y},${bar_width},${usage_height}^"
    status_line+="^d^^f4^" # buffer of 1
    status_line+="${p_mem}%"
    echo "M:$status_line"
}

swap() {
    local m_swap=$(free -m)
    local t_swap=$(echo "$m_swap" | awk '/^Swap:/ {print $2}')
    local u_swap=$(echo "$m_swap" | awk '/^Swap:/ {print $3}')
    if [[ "$u_swap" -eq 0 ]]; then
        return
    fi
    local p_swap=$(awk "BEGIN {printf \"%.0f\", ($u_swap/$t_swap)*100}")
    local usage_height=$((max_height * u_swap / 100))
    local usage_y=$((base_y + max_height - usage_height))
    local status_line=""
    status_line+="^c$grey^^r$base_x,${base_y},${bar_width},${max_height}^"
    status_line+="^c$white^^r${base_x},${usage_y},${bar_width},${usage_height}^"
    status_line+="^d^^f4^" # buffer of 1 
    status_line+="${p_swap}%"
    echo "|S:$status_line"
}

disk() {
    local usage_p2=$(df -h | grep '/dev/mmcblk0p2' | awk '{print $5}' | tr -d '%')
    local usage_p4=$(df -h | grep '/dev/mmcblk0p1' | awk '{print $5}' | tr -d '%')
    if [[ ! "$usage_p2" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        usage_p2=0
    fi
    if [[ ! "$usage_p4" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        usage_p4=0
    fi
    local status_line=""
    local -A usages=(
        [p2]=$usage_p2
        [p4]=$usage_p4
    )
    for partition in p2 p4; do
        local percentage=${usages[$partition]}
        local usage_height=$(($percentage * $max_height / 100))
        local usage_y=$((base_y + max_height - usage_height))
        status_line+="^c$grey^^r${base_x},${base_y},${bar_width},${max_height}^"
        status_line+="^c$white^^r${base_x},${usage_y},${bar_width},${usage_height}^"
        base_x=$((base_x + bar_width + gap))
    done
    status_line+="^d^^f8^" #Buffer of 1
    echo "DF:${status_line}R:${usage_p2}%-U:${usage_p4}%"
}

cpu_temperature(){
    local temp=$(awk '{print int($1 / 1000)}' /sys/class/thermal/thermal_zone0/temp)
    local max_temp=80
    local color=$white
    if [ "$temp" -gt "$max_temp" ]; then
        color=$red
    elif [ "$temp" -lt "$max_temp" ]; then
        color=$green
    fi
    local adj_y=5
    local usage_height=$(($temp * $max_height / $max_temp))
    local usage_y=$((adj_y + 10 - usage_height))
    local temp_icon="^c$black^"
    temp_icon+="^r2,${base_y},5,${max_height}^" #BG bar
    temp_icon+="^c$color^"
    temp_icon+="^r3,${usage_y},3,${usage_height}^" #C bar 
    temp_icon+="^c$black^"
    temp_icon+="^r1,11,8,5^" #two rectangles
    temp_icon+="^r2,10,6,7^" #to mimic a circle
    temp_icon+="^d^^f11^" #Buffer of 1
    echo "${temp_icon}${temp}°C"
}

battery() {
    local throttled=$(cat /sys/devices/platform/soc/soc:firmware/get_throttled)
    local capacity=0
    local status=""
    
    if [ $((throttled & 0x1)) -ne 0 ]; then
        status+="Under-voltage detected"
    fi
    if [ $((throttled & 0x2)) -ne 0 ]; then
        status+="ARM frequency capped"
    fi
    if [ $((throttled & 0x4)) -ne 0 ]; then
        status+="Currently throttled"
    fi
    if [ $((throttled & 0x8)) -ne 0 ]; then
        status+="Soft temperature limit active"
    fi
    if [ $((throttled & 0x10000)) -ne 0 ]; then
        status+="Under-voltage has occurred since last reboot"
    fi
    if [ $((throttled & 0x20000)) -ne 0 ]; then
        status+="ARM frequency capped has occurred since last reboot"
    fi
    if [ $((throttled & 0x40000)) -ne 0 ]; then
        status+="Throttling has occurred since last reboot"
    fi
    if [ $((throttled & 0x80000)) -ne 0 ]; then
        status+="Soft temperature limit has occurred since last reboot"
    fi

    if [ "$throttled" -eq 0 ]; then
        status+="No issues detected"
        capacity=100
    fi

    # Check the core voltage using vcgencmd
    local volt=$(vcgencmd measure_volts core | awk -F'=' '{print $2}')
    local fill_width=$(($capacity * 9 / 100)) # corresponds to width of bar
    local battery_icon="^c$black^"
    battery_icon+="^r1,6,13,8^"
    battery_icon+="^c$grey^"
    battery_icon+="^r3,8,9,4^"
    battery_icon+="^c$green^"
    battery_icon+="^r3,8,$fill_width,4^"
    battery_icon+="^c$black^"
    battery_icon+="^r14,7,2,4^"
    battery_icon+="^d^^f17^" #Buffer of 1
    echo "${battery_icon}${volt}"
}

wifi() {
    local iface=$(ip -o link show | grep -v "lo:" | awk -F': ' '{print $2}');
    local ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
    ssid="${ssid:-No WiFi}"
    ssid="${ssid:0:5}"
    local dwm=$(grep "$iface" /proc/net/wireless | awk '{ print int($4) }')
    if [ "$ssid" = "No WiFi" ]; then
        local signal=0
    else 
        local signal_normalized=$(( (dwm + 90) * 100 / 60 ))
        if [ $signal_normalized -gt 100 ]; then
            signal=100
        elif [ $signal_normalized -lt 0 ]; then
            signal=0
        else
            signal=$signal_normalized
        fi
    fi

    local color=$white
    if [ $signal -ge 66 ]; then
        color=$green
    elif [ $signal -le 33 ]; then
        color=$red
    elif [ $signal -gt 33 ] && [ $signal -lt 66 ]; then
        color=$yellow
    fi

    local max_bars=5
    local bars_filled=$((signal / 20))

    local wifi_icon="^c$color^"
    for i in 1 2 3 4 5; do
        local width=$(( (2 * i + 1) ))
        local height=$(( (2 * i + 1) ))
        local adj_y=$((max_height - height))
        if [ $i -le $bars_filled ]; then
            wifi_icon+="^c$color^"
        else
            wifi_icon+="^c$grey^"
        fi
        wifi_icon+="^r$((base_x + 2 * ( i - 3 ))),$((adj_y + 1)),$width,$height^"
    done
    wifi_icon+="^d^^f7^"

    echo " ${wifi_icon}${ssid} ${signal}%}"
}
status(){
    echo "$(cpu)|$(ram)|$(swap)$(disk)|$(cpu_temperature)|$(battery)|$(wifi)"
}
while true; do
    DISPLAY=:0
    xsetroot -name "$(status)"
done
