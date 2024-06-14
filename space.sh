#!/bin/bash

# Function to check and display available storage
check_storage() {
    # Get available storage in human-readable format, replacing 'i' with 'B' for consistency
    storage=$(df -h "$HOME" | awk 'NR==2 {gsub(/i/, "B", $4); print $4}')

    # Ensure storage is displayed as "0B" if it reads "0BB"
    if [ "$storage" == "0BB" ]; then
        storage="0B"
    fi

    # Display the available storage
    printf "\n\n\033[32m [ Available storage: $storage ]\n\033[0m\n\n"
}

# Call the function to check storage
check_storage
