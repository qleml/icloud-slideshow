#!/bin/bash

# Set the project directory environment variable
export ICLOUD_SLIDESHOW_DIR=$(pwd)

# Optionally, add this to the user's shell profile for persistence
echo "export ICLOUD_SLIDESHOW_DIR=$(pwd)" >> ~/.bashrc

# Source the profile to apply changes immediately
source ~/.bashrc

echo "Environment variables set successfully."