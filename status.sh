#!/bin/bash

# Define an array of clock emojis from 🕐 to 🕛

# Function to translate English day names to French
translate_day() {
    case $1 in
        Monday) echo "Lundi" ;;
        Tuesday) echo "Mardi" ;;
        Wednesday) echo "Mercredi" ;;
        Thursday) echo "Jeudi" ;;
        Friday) echo "Vendredi" ;;
        Saturday) echo "Samedi" ;;
        Sunday) echo "Dimanche" ;;
        *) echo "$1" ;;  # Return the original name if not found
    esac
}

# Function to translate English month names to French
translate_month() {
    case $1 in
        January) echo   "Janvier" ;;
        February) echo  "Février" ;;
        March) echo     "Mars" ;;
        April) echo     "Avril" ;;
        May) echo       "Mai" ;;
        June) echo      "Juin" ;;
        July) echo      "Juillet" ;;
        August) echo    "Août" ;;
        September) echo "Septembre" ;;
        October) echo   "Octobre" ;;
        November) echo  "Novembre" ;;
        December) echo  "Décembre" ;;
        *) echo "$1" ;;  # Return the original name if not found
    esac
}

# Get the last two digits of the year
YEAR=$(date +"%y")
DATE_YMD=$(date +"%Y %m %d")  # Date in YYYY-MM-DD format
DATE_DMY=$(date +"%d-%m-%y")  # Date in DD-MM-YY format
EN_DAY=$(date +"%A")
EN_MONTH=$(date +"%B")
FR_DAY=$(translate_day "$EN_DAY")
FR_MONTH=$(translate_month "$EN_MONTH")


# Get the power status
power_status=$(upower -i $(upower -e | grep '/battery') | grep -E "state|percentage")

while true; do
    # Get current time and date
    HOUR_12=$(date +"%I")  # 12-hour format with leading zero
    MINUTE=$(date +"%M")  # Get the minutes
    HOUR_24=$(date +"%H:%M")  # 24-hour format (HH:MM)
    AMPM=$(date +"%p")  # Get AM or PM
    # Translate to French
    DAY_NUM=$(date +"%d")
    # Get the free space and total space in human-readable format
    disk_info=$(df -h | grep '/dev/nvme0n1p2')
    percentage_used=$(echo "$disk_info" | awk '{print $5}')
    # Extract the free and total space from the output
    free_space=$(echo $disk_info | awk '{print $4}')
    # Extract the used and total space from the output
    used_space=$(echo $disk_info | awk '{print $3}')
    total_space=$(echo $disk_info | awk '{print $2}')
    disk_space="$percentage_used"

    # Get the first character of the minute
    MINUTE_FIRST_CHAR="${MINUTE:0:1}"
    # Check if HOUR_12 starts with a leading zero and remove it if present
    if [[ "${HOUR_12:0:1}" == "0" ]]; then
        HOUR_12="${HOUR_12:1:1}"
    fi

    padding=" "

    # Format output for lemonbar
    #OUTPUT="${padding}($HOUR_12:$MINUTE_FIRST_CHAR) - ($HOUR_24) - ($DATE)"


    romanise() {
        local input="$1"
        local result="$input"

        # Define a mapping of numbers to Roman numerals
        declare -A roman_map=(
            [10]="X" [11]="I" [12]="0"
        )

        # Replace exact matches in the input
        for num in "${!roman_map[@]}"; do
            result="${result//$num/${roman_map[$num]}}"
        done

        echo "$result"
    }

    # Optimised time
    
    # Even minute format: red text on black background
#    if [[ "$HOUR_12" == "12" ]]; then
#        HOUR_12="0"
#    elif [[ "$HOUR_12" == "11" ]]; then
#        HOUR_12="I"
#    elif [[ "$HOUR_12" == "10" ]]; then
#        HOUR_12="X"
#    fi

    HOUR_12=$(romanise $HOUR_12)
    #indice=" ${AMPM:0:1}"
    TIME="$HOUR_12:$MINUTE_FIRST_CHAR${indice}"
    DATE="$DATE_DMY"

    DATE=$(romanise $DATE)

    # Multiple time format

    # Check if the minute is even or odd
#    if (( MINUTE % 2 == 0 )); then
#        # Even minute format: red text on black background
#        if [[ "$HOUR_12" == "12" ]]; then
#            HOUR_12="0"
#        elif [[ "$HOUR_12" == "11" ]]; then
#            HOUR_12="I"
#        elif [[ "$HOUR_12" == "10" ]]; then
#            HOUR_12="X"
#        fi
#
#        #indice=" ${AMPM:0:1}"
#        TIME="$HOUR_12:$MINUTE_FIRST_CHAR${indice}"
#        DATE="$DATE_DMY"
#    else
#        # Odd minute format: white text on blue background
##        if [[ "${HOUR_24:0:2}" == "00" ]] || [[ "${HOUR_24:0:2}" == "12" ]] ; then
##            HOUR_24="XX:$MINUTE"
##        fi
#        TIME="$HOUR_24"
#        DATE="$FR_DAY $DAY_NUM $FR_MONTH"
#    fi

    bat_text=""

    if echo "$power_status" | grep -q "discharging"; then
    	# pourcent
    	pour_cent=$(acpi | awk '{print $4}')
    	pour_cent=$(echo ${pour_cent} | sed 's/,//')
    	if [ ${pour_cent//[!0-9]/} -gt $low ]; then
    		BAT="${pour_cent}"
    	else
    		BAT="${pour_cent}"
    	fi
        n_pour_cent=${pour_cent%\%}
        # Assume $pour_cent holds the battery percentage as an integer
        if [ "$n_pour_cent" -ge 80 ]; then
            battery_char="█"  # Full battery
        elif [ "$n_pour_cent" -ge 60 ]; then
            battery_char="▓"  # 75% battery
        elif [ "$n_pour_cent" -ge 40 ]; then
            battery_char="▒"  # 50% battery
        elif [ "$n_pour_cent" -ge 20 ]; then
            battery_char="░"  # 25% battery
        else
            battery_char="▁"  # Low battery
        fi
        bat_text="($battery_char $pour_cent)"
    fi
    
    task=""
    # Check if /tmp/todo.md exists and is not empty
    if [[ -s "/tmp/todo.tmp" ]]; then
        # Pick a random line from /tmp/todo.md
        line=$(shuf -n 1 "/tmp/todo.tmp")
        # Remove the first 3 and last 3 characters
        task="(${line:2:-11})"
    fi
    offset=""
    # Output the formatted text to lemonbar
    echo "${offset}$bat_text [$TIME] [$DATE] [$disk_space] $task"

    # Sleep for 60 seconds to update the time
    sleep 60
done

