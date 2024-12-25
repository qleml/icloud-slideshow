#!/bin/bash

# Check if ICLOUD_SLIDESHOW_PATH is set
if [ -z "$ICLOUD_SLIDESHOW_PATH" ]; then
    echo "Error: ICLOUD_SLIDESHOW_PATH is not set."
    exit 1
fi

xhost +
export DISPLAY=:0.0

# Function to run feh
run_feh() {
    echo "Starting feh..."
    feh --slideshow-delay 7 --recursive -F --auto-rotate $ICLOUD_SLIDESHOW_DIR media
}

# Start the feh process
run_feh
