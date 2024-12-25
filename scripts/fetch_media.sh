#!/bin/bash

# Check if ICLOUD_SLIDESHOW_PATH is set
if [ -z "$ICLOUD_SLIDESHOW_PATH" ]; then
    echo "Error: ICLOUD_SLIDESHOW_PATH is not set."
    exit 1
fi

FETCH_SCRIPT_DIR=$ICLOUD_SLIDESHOW_PATH/src
PYTHON_FILE=fetch_media.py

export TERM=xterm
source $ICLOUD_SLIDESHOW_PATH/venv/bin/activate

# Fetch media
echo "Fetching media..."
if python $FETCH_SCRIPT_DIR/$PYTHON_FILE $ICLOUD_SLIDESHOW_PATH; then
    echo "Media fetched successfully."
else
    echo "Error fetching media. Continuing to restart feh."
fi

# Check if a feh process is running
if pgrep -x "feh" > /dev/null; then
    echo "feh is running. Restarting feh process."
    # Kill the current feh process
    pkill feh

    # Restart the feh process
    $ICLOUD_SLIDESHOW_PATH/scripts/run_feh.sh
else
    echo "feh is not running. Skipping restart."
fi