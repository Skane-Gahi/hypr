#!/bin/bash
set -e

# Device used for brightness control
device="amdgpu_bl0"
# Retrieve max value of the device
max_value=$(brightnessctl -d $device max)

# Get the brightness value as a percentage
get_value () {
    local value=$(brightnessctl -d "$device" get)
    local percentage=$(echo "scale=2; $value / $max_value * 100" | bc)
    local rounded_percentage=$(echo "($percentage + 0.5) / 1" | bc)

    echo $rounded_percentage
}

# Check argument to know what to do
if [ "$1" == "up" ]; then
    # Increase brightness by 10%
    brightnessctl -d "$device" set +10%
fi
if [ "$1" == "down" ]; then
    # Decrease brightness by 10%
    brightnessctl -d "$device" set 10%-
fi

# Get the updated brightness value
value=$(get_value)

# Check if the widget is already opened
eww_window=$(eww windows | grep "brightness")
first_char=${eww_window:0:1}

# Open the widget if not opened
if [ "$first_char" == "b" ]; then
    eww open brightness-control
fi
# Update the eww variable
eww update brightness-value="$value"

# Wait 2 secs
sleep 2
# Check if the v has changed
new_value=$(get_value)
# If not, close the widget
if [ "$new_value" == "$value" ]; then
    eww close brightness-control
fi