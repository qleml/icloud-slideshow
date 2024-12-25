#!/bin/bash

xhost +
export DISPLAY=:0.0

# Function to read the slideshow interval from config.yaml
get_slideshow_interval() {
    local interval=$(grep 'SLIDESHOW_INTERVAL' $ICLOUD_SLIDESHOW_PATH/config.yaml | awk '{print $2}')
    echo $interval
}

# Function to run feh
run_feh() {
    local interval=$(get_slideshow_interval)
    echo "Starting feh with slideshow interval of $interval seconds..."
    feh --slideshow-delay $interval --recursive -F $ICLOUD_SLIDESHOW_PATH/media-rotated/
}

# Start the feh process
run_feh