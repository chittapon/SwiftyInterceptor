#!/bin/sh

# work directory
cd "$(dirname "$0")"

# Set file for logs
exec > server.log 2>&1

# Run the mock server and send it to background
./App serve --port 8888 &

# Record the PID of the last background process
echo $! > server.pid