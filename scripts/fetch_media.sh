#!/bin/bash
PROJECT_DIR=/home/ccc/dev/photo-stream
FETCH_SCRIPT_DIR=$PROJECT_DIR/src
PYTHON_FILE=fetch_media.py
DIST_DIR=$PROJECT_DIR/dist/
EXECUTABLE=fetch_media_executable
LOG_DIR=$PROJECT_DIR/log/fetch_media.log

export TERM=xterm
HOME=/home/ccc
source $PROJECT_DIR/venv/bin/activate

# Fetch media
echo "Fetching media..."
if python $FETCH_SCRIPT_DIR/$PYTHON_FILE $PROJECT_DIR; then
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
    $PROJECT_DIR/scripts/run_feh.sh
else
    echo "feh is not running. Skipping restart."
fi