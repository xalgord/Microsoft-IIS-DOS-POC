#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <Domain or IP>"
    exit 1
fi

HOST=$1

echo "[*] Audit Started for $HOST"

# Remove 'https://' if the user provided it
HOST=$(echo "$HOST" | sed -e 's|https://||' -e 's|http://||')

# Fetch HTTP headers
HEADERS=$(curl -s -I "https://$HOST")

# Debug: Print Headers (optional)
echo "[DEBUG] HTTP Headers Received:"
echo "$HEADERS"

# Check if IIS is present
if echo "$HEADERS" | grep -iq "Microsoft-IIS"; then
    echo "[*] Detected IIS Server"
else
    echo "[*] NOT IIS"
    exit 1
fi

# Check for Range Header vulnerability
RESPONSE=$(curl -s -I -H "Range: bytes=0-18446744073709551615" "https://$HOST")

if echo "$RESPONSE" | grep -q "Requested Range Not Satisfiable"; then
    echo "[!!] Looks VULN"
elif echo "$RESPONSE" | grep -q "The request has an invalid header name"; then
    echo "[*] Looks Patched"
else
    echo "[*] Unexpected response, cannot discern patch status"
fi
