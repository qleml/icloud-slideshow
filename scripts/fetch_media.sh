#!/bin/bash
ICLOUD_SLIDESHOW_DIR=/home/ccc/dev/photo-stream
FETCH_SCRIPT_DIR=$ICLOUD_SLIDESHOW_DIR/src
PYTHON_FILE=fetch_media.py
DIST_DIR=$ICLOUD_SLIDESHOW_DIR/dist/
EXECUTABLE=fetch_media_executable
LOG_DIR=$ICLOUD_SLIDESHOW_DIR/log/fetch_media.log

export TERM=xterm
HOME=/home/ccc
source $ICLOUD_SLIDESHOW_DIR/venv/bin/activate

# Fetch media
echo "Fetching media..."
if python $FETCH_SCRIPT_DIR/$PYTHON_FILE $ICLOUD_SLIDESHOW_DIR; then
    echo "Media fetched successfully."
else
    echo "Error fetching media. Continuing to restart feh."
    if /bin/bash /home/ccc/dev/photo-stream/scripts/push_log.sh $LOG_DIR
    then
        echo "Log file pushed successfully."
    else
        echo "Error pushing log file."
    fi
fi

# Check if a feh process is running
if pgrep -x "feh" > /dev/null; then
    echo "feh is running. Restarting feh process."
    # Kill the current feh process
    pkill feh

    # Restart the feh process
    $ICLOUD_SLIDESHOW_DIR/scripts/run_feh.sh
else
    echo "feh is not running. Skipping restart."
fi