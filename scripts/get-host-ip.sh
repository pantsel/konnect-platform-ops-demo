#!/bin/bash

# Function to get the host IP on macOS
get_ip_mac() {
    local ip
    # Try to get IP address using ipconfig for different interfaces
    for interface in en0 en1 en2; do
        ip=$(ipconfig getifaddr "$interface" 2>/dev/null)
        if [ -n "$ip" ]; then
            break
        fi
    done
    # If ipconfig did not work, try ifconfig
    if [ -z "$ip" ]; then
        ip=$(ifconfig | awk '/inet / && !/127.0.0.1/ {print $2; exit}')
    fi
    echo $ip
}

# Function to get the host IP on Windows (Git Bash or WSL)
get_ip_win() {
    local ip
    # Use ipconfig to get the IP address
    ip=$(ipconfig | awk '/IPv4 Address/ {print $NF}')
    if [ -z "$ip" ]; then
        ip=$(ipconfig | awk '/IPv4 Address/ {print $14}')
    fi
    echo $ip
}

# Determine the OS and call the respective function
os=$(uname -s)

case "$os" in
    Darwin)
        # macOS
        ip_address=$(get_ip_mac)
        ;;
    MINGW*|CYGWIN*|MSYS*)
        # Windows
        ip_address=$(get_ip_win)
        ;;
    Linux)
        # Linux (assuming WSL)
        ip_address=$(hostname -I | awk '{print $1}')
        ;;
    *)
        echo "Unsupported OS."
        exit 1
        ;;
esac

# Output the IP address
if [ -n "$ip_address" ]; then
    echo $ip_address
else
    echo "Unable to determine the IP address."
    exit 1
fi
