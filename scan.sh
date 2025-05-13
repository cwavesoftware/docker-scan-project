#!/bin/bash

led-heartbeat

# Detect the IP address and network range
slack-notif DEBUG "$(ifconfig)"
IP_ADDRESS=$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1)
if [ -z "$IP_ADDRESS" ]; then
    echo "No IP address detected. Exiting."
    exit 1
fi

# Extract the network range (CIDR notation)
NETWORK_RANGE=$(ip -o -f inet addr show | awk '/eth0/ {print $4}' | head -n 1)
if [ -z "$NETWORK_RANGE" ]; then
    echo "Unable to determine network range. Exiting."
    exit 1
fi

msg="$(date):eth0 IP Address: $IP_ADDRESS"
echo "$msg"
slack-notif DEBUG "$msg"
msg="$(date):eth0 Network Range: $NETWORK_RANGE"
echo "$msg"
slack-notif DEBUG "$msg"

# Run nmap scan on the detected network range
msg="$(date):Starting nmap scan on network range: $NETWORK_RANGE"
echo "$msg"
slack-notif DEBUG "$msg"

OUTPUT_FILE="nmap_$IP_ADDRESS"
nmap -Pn -T5 -vv "$NETWORK_RANGE" -oA "$OUTPUT_FILE"
msg="$(date):Nmap scan completed. Output saved to $OUTPUT_FILE"
echo "$msg"
slack-notif DEBUG "$msg"
slack-notif DEBUG "$(cat $OUTPUT_FILE.nmap)"

led-on
sleep 99999