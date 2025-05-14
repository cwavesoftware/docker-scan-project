#!/bin/bash

led-heartbeat
# Source the .env file
if [ -f .env ]; then
    source .env
fi
NMAP_OUT_TO_SLACK=${NMAP_OUT_TO_SLACK:-true}

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

OUTPUT_FILE="nmap_$(echo $NETWORK_RANGE | sed 's/\//_/g')_$(date +%Y%m%d%H%M%S)"
nmap -Pn -T5 -A -vv -p- "$NETWORK_RANGE" -oA "$OUTPUT_FILE"
msg="$(date):Nmap scan completed. Output saved to $OUTPUT_FILE"
echo "$msg"
slack-notif DEBUG "$msg"
if [ "$NMAP_OUT_TO_SLACK" == true ]; then
    msg="$(date):Sending nmap output to Slack"
    echo "$msg"
    slack-notif DEBUG "$msg"
    slack-notif DEBUG "$(cat $OUTPUT_FILE.nmap)"
else
    msg="$(date):Nmap output not sent to Slack as NMAP_OUT_TO_SLACK is set to false."
    echo "$msg"
    slack-notif DEBUG "$msg"
fi

led-off
while true; do
    sleep 1
done