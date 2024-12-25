#!/bin/bash

# Define the environment variable and project path
export ICLOUD_SLIDESHOW_PATH=$(pwd)

# Remove cron jobs that contain the environment variable
echo "Removing cron jobs..."
(crontab -l 2>/dev/null | grep -v "$ICLOUD_SLIDESHOW_PATH" | crontab -)

# Remove the environment variable from ~/.bashrc
echo "Removing environment variable from ~/.bashrc..."
sed -i "/export ICLOUD_SLIDESHOW_PATH=$ICLOUD_SLIDESHOW_PATH/d" ~/.bashrc

# Delete the virtual environment folder
echo "Deleting the virtual environment folder..."
if [ -d "venv" ]; then
    rm -rf venv
    echo "Virtual environment deleted."
else
    echo "Virtual environment folder does not exist."
fi

echo "Uninstallation completed successfully."
