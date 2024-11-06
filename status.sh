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
DATE_YMD=$(date +"%Y-%m-%d")  # Date in YYYY-MM-DD format
EN_DAY=$(date +"%A")
EN_MONTH=$(date +"%B")
FR_DAY=$(translate_day "$EN_DAY")
FR_MONTH=$(translate_month "$EN_MONTH")

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

    # Extract the free and total space from the output
    free_space=$(echo $disk_info | awk '{print $4}')
    # Extract the used and total space from the output
    used_space=$(echo $disk_info | awk '{print $3}')
    total_space=$(echo $disk_info | awk '{print $2}')
    disk_space="$used_space/$total_space"

    # Get the first character of the minute
    MINUTE_FIRST_CHAR="${MINUTE:0:1}"
    # Check if HOUR_12 starts with a leading zero and remove it if present
    if [[ "${HOUR_12:0:1}" == "0" ]]; then
        HOUR_12="${HOUR_12:1:1}"
    fi

    padding=" "

    # Format output for lemonbar
    #OUTPUT="${padding}($HOUR_12:$MINUTE_FIRST_CHAR) - ($HOUR_24) - ($DATE)"

    # Check if the minute is even or odd
    if (( MINUTE % 2 == 0 )); then
        # Even minute format: red text on black background
        TIME="$HOUR_12:$MINUTE_FIRST_CHAR $AMPM"
        DATE="$FR_DAY $DAY_NUM $FR_MONTH"
    else
        # Odd minute format: white text on blue background
        TIME="$HOUR_24"
        DATE="$DATE_YMD"
    fi

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

    # Output the formatted text to lemonbar
    echo "$battery_char ($TIME) - ($DATE) - ($disk_space)"

    # Sleep for 60 seconds to update the time
    sleep 60
done

