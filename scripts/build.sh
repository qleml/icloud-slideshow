#!/bin/bash

ICLOUD_SLIDESHOW_DIR=~/dev/photo-stream/
OUTPUT_DIR=$ICLOUD_SLIDESHOW_DIR/dist/
BUILD_DIR=$ICLOUD_SLIDESHOW_DIR/build/
SPEC_DIR=$ICLOUD_SLIDESHOW_DIR/spec/
OUTPUT_NAME=fetch_media_executable
LOG_FILE=$ICLOUD_SLIDESHOW_DIR/log/build_log.log

source $ICLOUD_SLIDESHOW_DIR/venv/bin/activate

# Create log directory if it doesn't exist
mkdir -p $(dirname $LOG_FILE)

# Redirect all output to the log file (overwrite mode)
exec > >(tee $LOG_FILE) 2>&1

echo "Starting build process..."

# Fetch latest git version
echo "Starting SSH agent..."
eval "$(ssh-agent -s)"
echo "Adding SSH key..."
ssh-add ~/.ssh/github

echo "Navigating to project directory..."
cd $ICLOUD_SLIDESHOW_DIR

echo "Pulling latest changes from git..."
if git pull; then
    echo "Git pull successful."
else
    echo "Git pull failed. Exiting build process."
    exit 1
fi

echo "Running PyInstaller..."
PYTHON_LIB=$(python3 -c 'import sysconfig; print(sysconfig.get_config_var("LIBDIR"))')/libpython3.12.so
if pyinstaller --onefile --add-binary "$PYTHON_LIB:." --distpath $OUTPUT_DIR --workpath $BUILD_DIR --specpath $SPEC_DIR --name $OUTPUT_NAME $ICLOUD_SLIDESHOW_DIR/src/fetch_media.py; then
    echo "Build process completed successfully."
else
    echo "Build process failed."
    exit 1
fi