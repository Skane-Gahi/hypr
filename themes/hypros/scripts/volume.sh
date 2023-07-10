#!/bin/bash

# Get the volume level as integer
get_value () {
    # Get the volume from wpctl and extract the value
    local wpctl_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oE '[0-9]+([.][0-9]+)?')
    # Multiply the value by 100
    local float_level=$(echo "$wpctl_output * 100" | bc)
    # Cast it to an integer
    local int_level=$(printf "%.0f" "$float_level")

    # return the integer
    echo $int_level
}

# Check argument to know what to do
if [ $1 == "up" ]; then
    # Increase volume by 10%
    wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 10%+
fi
if [ $1 == "down" ]; then
    # Decrease volume by 10%
    wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 10%-
fi

# Retrieve the new volume level
volume_value=$(get_value)

# Check if the widget is already opened
eww_window=$(eww windows | grep "volume")
is_opened=${eww_window:0:1}

# Open the widget if not opened
if [ "$is_opened" == "v" ]; then
    eww open volume-control
fi
# Update the eww variable
eww update volume-value=$volume_value

# Wait 2 secs
sleep 2
# Check if the volume has changed
new_volume_value=$(get_value)
# If not, close the widget
if [ "$new_volume_value" == "$volume_value" ]; then
    eww close volume-control
fi