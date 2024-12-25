#!/bin/bash

xhost +
export DISPLAY=:0.0

# Function to run feh
run_feh() {
    echo "Starting feh..."
    feh --slideshow-delay 7 --recursive -F $ICLOUD_SLIDESHOW_DIR/media-rotated/
}

# Start the feh process
run_feh
