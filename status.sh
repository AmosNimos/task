#!/bin/bash

# Define arrays for French translations of day and month names
declare -A days=( [Monday]="Lundi" [Tuesday]="Mardi" [Wednesday]="Mercredi" [Thursday]="Jeudi" [Friday]="Vendredi" [Saturday]="Samedi" [Sunday]="Dimanche" )
declare -A months=( [January]="Janvier" [February]="Février" [March]="Mars" [April]="Avril" [May]="Mai" [June]="Juin" [July]="Juillet" [August]="Août" [September]="Septembre" [October]="Octobre" [November]="Novembre" [December]="Décembre" )

# Get the last two digits of the year and current date
YEAR=$(date +"%y")
DATE_YMD=$(date +"%Y-%m-%d")  # Date in YYYY-MM-DD format
DATE_DMY=$(date +"%d-%m-%y")  # Date in DD-MM-YY format
EN_DAY=$(date +"%A")
EN_MONTH=$(date +"%B")
FR_DAY=${days[$EN_DAY]}
FR_MONTH=${months[$EN_MONTH]}

# Get the power status
power_status=$(upower -i $(upower -e | grep '/battery') | grep -E "state|percentage")

# Helper function for romanising numbers (simplified)
romanise() {
    local input="$1"
    declare -A roman_map=( [10]="X" [11]="I" [12]="0" )
    for num in "${!roman_map[@]}"; do
        input="${input//$num/${roman_map[$num]}}"
    done
    echo "$input"
}

# Trap any error in the script and display an error message
trap 'echo "Unexpected loop end for $0, no longer updating..." | tee -a /tmp/status_error.log; exit 1' ERR


# Main loop
while true; do
    # Get current time and date (simplified format)
    HOUR_12=$(date +"%-I")
    MINUTE=$(date +"%M")
    DAY_NUM=$(date +"%d")

    # Round minutes to nearest 10
    MINUTE=$(( (10#$MINUTE + 5) / 10 * 10 ))
    if [ "$MINUTE" -gt 50 ]; then
        MINUTE="+"
    fi

    HOUR_24=$(date +"%H:%M")
    TIME=$(romanise $HOUR_12):${MINUTE:0:1}

    # Disk space usage
    disk_info=$(df -h | grep '/dev/nvme0n1p2')
    disk_space=$(echo "$disk_info" | awk '{print $5}')

    # Battery status
    bat_text=""
    if echo "$power_status" | grep -q "discharging"; then
        pour_cent=$(acpi | awk '{print $4}' | sed 's/,//')
        n_pour_cent=${pour_cent%\%}
        if [ "$n_pour_cent" -ge 80 ]; then
            battery_char="█"
        elif [ "$n_pour_cent" -ge 60 ]; then
            battery_char="▓"
        elif [ "$n_pour_cent" -ge 40 ]; then
            battery_char="▒"
        elif [ "$n_pour_cent" -ge 20 ]; then
            battery_char="░"
        else
            battery_char="▁"
        fi
        bat_text="($battery_char $pour_cent)"
    fi

    # Task from todo.tmp (if available)
    task=""
    if [[ -s "/tmp/todo.tmp" ]]; then
        line=$(shuf -n 1 "/tmp/todo.tmp")
        task="(${line:2:-11})"
    fi

    # Output to lemonbar
    echo "$bat_text [$TIME] [$DATE_DMY] [$disk_space] $task"
    
    sleep 60
done

echo "Unexpected loop end for $0, no longer updating..."
