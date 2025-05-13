#!/bin/bash

# Detect the IP address and network range
IP_ADDRESS=$(hostname -i | awk '{print $1}')
if [ -z "$IP_ADDRESS" ]; then
    echo "No IP address detected. Exiting."
    exit 1
fi

# Extract the network range (CIDR notation)
NETWORK_RANGE=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n 1)
if [ -z "$NETWORK_RANGE" ]; then
    echo "Unable to determine network range. Exiting."
    exit 1
fi

echo "Detected IP Address: $IP_ADDRESS"
echo "Detected Network Range: $NETWORK_RANGE"

# Run nmap scan on the detected network range
echo "Starting nmap scan on network range: $NETWORK_RANGE"
OUTPUT_FILE="$HOME/nmap_$IP_ADDRESS"
nmap -Pn -T5 -vv "$NETWORK_RANGE" -oA "$OUTPUT_FILE"

