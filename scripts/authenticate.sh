#!/bin/bash

# Check if icloudpd is installed
if ! command -v icloudpd &> /dev/null; then
    echo "icloudpd is not installed. Please install it first."
    exit 1
fi

# Prompt the user for their Apple ID
read -p "Enter your Apple ID email: " APPLE_ID

# Run icloudpd to authenticate
icloudpd --username "$APPLE_ID" --authenticate-only

# Check if the authentication was successful
if [ $? -eq 0 ]; then
    echo "Authentication successful. Please complete the 2FA prompts."
else
    echo "Authentication failed. Please try again."
    exit 1
fi

echo "2FA completed successfully."