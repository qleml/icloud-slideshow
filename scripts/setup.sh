#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Set the project directory environment variable
export ICLOUD_SLIDESHOW_PATH=$(pwd)

# Append the environment variable to ~/.bashrc if not already present
if ! grep -q "export ICLOUD_SLIDESHOW_PATH=$(pwd)" ~/.bashrc; then
    echo "export ICLOUD_SLIDESHOW_PATH=$(pwd)" >> ~/.bashrc
    source ~/.bashrc
fi

echo "Environment variables set successfully."

# Install venv package if not installed
if ! command_exists python3-venv; then
    echo "Installing python3-venv..."
    sudo apt-get update
    sudo apt-get install -y python3-venv
fi

# Create a virtual environment only if it doesn't exist
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Virtual environment created."
else
    echo "Virtual environment already exists. Skipping creation."
fi
# Activate the virtual environment
source venv/bin/activate

# Install required Python packages
pip install -r requirements.txt

# Install feh if not installed
if ! command_exists feh; then
    echo "Installing feh..."
    sudo apt-get update
    sudo apt-get install -y feh
fi

# Deactivate the virtual environment
deactivate


# Define the cron jobs
CRON_JOB_FETCH="0 3 * * * /bin/bash $ICLOUD_SLIDESHOW_PATH/scripts/fetch_media.sh"
CRON_JOB_REBOOT="@reboot /bin/bash -c 'sleep 10; $ICLOUD_SLIDESHOW_PATH/scripts/run_feh'"

# Add cron jobs only if they do not already exist
# Fetch job
(crontab -l 2>/dev/null | grep -qF "$CRON_JOB_FETCH") || (crontab -l 2>/dev/null; echo "$CRON_JOB_FETCH") | crontab -

# Reboot job
(crontab -l 2>/dev/null | grep -qF "$CRON_JOB_REBOOT") || (crontab -l 2>/dev/null; echo "$CRON_JOB_REBOOT") | crontab -

echo "Cron jobs checked and added (if not already present)."

echo "Setup completed successfully."