#!/bin/bash

PROJECT_DIR=/home/ccc/dev/photo-stream/

xhost +
export DISPLAY=:0.0

# Function to run feh
run_feh() {
    echo "Starting feh..."
    feh --slideshow-delay 8 --recursive -F $PROJECT_DIR/media-rotated/
}

# Start the feh process
run_feh
