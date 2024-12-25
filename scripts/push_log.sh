#!/bin/bash

# Check if the directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_to_push>"
    exit 1
fi

DIRECTORY_TO_PUSH=$1
ICLOUD_SLIDESHOW_PATH=/home/ccc/dev/photo-stream/

# Start the SSH agent and add the SSH key
echo "Starting SSH agent..."
eval "$(ssh-agent -s)"
echo "Adding SSH key..."
ssh-add ~/.ssh/github

# Navigate to the project directory
echo "Navigating to project directory..."
cd $ICLOUD_SLIDESHOW_PATH


# Add the files in the specified directory to the staging area
echo "Adding files in $DIRECTORY_TO_PUSH to staging area..."
git add $DIRECTORY_TO_PUSH

# Commit the changes
echo "Committing changes..."
git commit -m "Update log files in $DIRECTORY_TO_PUSH"

# Push the changes to the remote repository
echo "Pushing changes to GitHub..."
git push

echo "Files in $DIRECTORY_TO_PUSH pushed to GitHub successfully."
