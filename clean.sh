#!/bin/bash

# Print a beautiful banner
echo -e "\033[1;36m"
cat << "EOF"
 ██████╗ ██╗   ██╗███████╗███╗   ███╗██████╗ ██████╗  ██████╗ ███████╗
 ██╔══██╗██║   ██║██╔════╝████╗ ████║██╔══██╗██╔══██╗██╔═══██╗██╔════╝
 ██████╔╝██║   ██║█████╗  ██╔████╔██║██████╔╝██║  ██║██║   ██║███████╗
 ██╔═══╝ ██║   ██║██╔══╝  ██║╚██╔╝██║██╔══██╗██║  ██║██║   ██║╚════██║
 ██║     ╚██████╔╝███████╗██║ ╚═╝ ██║██████╔╝██████╔╝╚██████╔╝███████║
 ╚═╝      ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝
EOF
echo -e "\033[0m\n"

# Function to calculate and display disk usage
display_disk_usage() {
    local storage
    storage=$(df -h "$HOME" | awk 'NR==2 {gsub(/i/, "B", $4); print $4}')
    if [ "$storage" == "0BB" ]; then
        storage="0B"
    fi
    echo -e "\033[1;33mDisk Usage:\033[0m"
    echo "[ Available storage: $storage ]"
}

# Function to clean the system
clean_system() {
    echo -e "\033[1;31mCleaning in progress...\033[0m"

    local should_log=0
    if [[ "$1" == "-p" || "$1" == "--print" ]]; then
        should_log=1
    fi

    clean_glob() {
        [[ -z "$1" ]] && return 0

        for arg in "$@"; do
            if [[ $should_log -eq 1 && -e "$arg" ]]; then
                echo "Deleting: $arg"
                du -sh "$arg" 2>/dev/null
            fi
            /bin/rm -rfv "$arg" 2>/dev/null
        done
    }

    shopt -s nullglob  # Resolve unmatched globs as empty strings

    echo -e "\033[1;34mCleaning caches and temporary files...\033[0m"

    # 42 Caches
    clean_glob "$HOME/Library/*.42*" "$HOME/*.42*" "$HOME/.zcompdump*" "$HOME/.cocoapods.42_cache_bak*"

    # Trash
    clean_glob "$HOME/.Trash/*"

    # General Caches
    /bin/chmod -R 777 "$HOME/Library/Caches/Homebrew" 2>/dev/null || true
    clean_glob "$HOME/Library/Caches/*" "$HOME/Library/Application Support/Caches/*"

    # Specific Application Caches
    local app_dirs=(
        "AddressBook" "BraveSoftware" "CallHistoryDB" "CallHistoryTransactions" "CloudDocs" "Code"
        "CrashReporter" "DiskImages" "Dock" "FileProvider" "Firefox" "Google" "Knowledge"
        "LimeChat" "Mozilla" "Postman" "Quick Look" "Spotify" "System Preferences"
        "com.apple.ProtectedCloudStorage" "com.apple.backgroundtaskmanagementagent" "com.apple.kvs"
        "com.apple.replayd" "com.apple.sharedfilelist" "com.apple.spotlight" "com.apple.touristd"
        "com.apple.transparencyd" "discord" "dmd" "iTerm2" "icdd" "syncdefaultsd" "transparencyd"
    )

    for app_dir in "${app_dirs[@]}"; do
        clean_glob "$HOME/Library/Application Support/$app_dir/Cache/*" \
                   "$HOME/Library/Application Support/$app_dir/CachedData/*" \
                   "$HOME/Library/Application Support/$app_dir/Service Worker/CacheStorage/*" \
                   "$HOME/Library/Application Support/$app_dir/Crashpad/completed/*" \
                   "$HOME/Library/Application Support/$app_dir/Code Cache/js*"
    done

    # .DS_Store files
    clean_glob "$HOME/Desktop/**/*/.DS_Store"

    # Temporary downloaded files from browsers
    clean_glob "$HOME/Library/Application Support/Chromium/Default/File System"
    clean_glob "$HOME/Library/Application Support/Chromium/Profile [0-9]/File System"
    clean_glob "$HOME/Library/Application Support/Google/Chrome/Default/File System"
    clean_glob "$HOME/Library/Application Support/Google/Chrome/Profile [0-9]/File System"

    # Piscine (pool) related files
    clean_glob "$HOME/Desktop/Piscine Rules *.mp4"
    clean_glob "$HOME/Desktop/PLAY_ME.webloc"

    echo -e "\033[1;32mCleaning completed successfully!\033[0m"
}

# Display disk usage before cleaning
display_disk_usage

# Ask for confirmation
read -rp "$(echo -e "\033[1;33mThis script will clean your system. Do you want to continue? (y/n) \033[0m")" confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    # Capture disk usage before cleaning
    initial_storage=$(df -h "$HOME" | awk 'NR==2 {gsub(/i/, "B", $4); print $4}')
    
    # Perform the cleaning
    clean_system "$@"

    # Capture disk usage after cleaning
    final_storage=$(df -h "$HOME" | awk 'NR==2 {gsub(/i/, "B", $4); print $4}')

    # Display the freed space
    echo -e "\033[1;33mDisk Usage Before Cleaning:\033[0m [ Available storage: $initial_storage ]"
    echo -e "\033[1;33mDisk Usage After Cleaning:\033[0m [ Available storage: $final_storage ]"
else
    echo -e "\033[1;31mCleaning canceled.\033[0m"
fi

# Display disk usage after cleaning
display_disk_usage

