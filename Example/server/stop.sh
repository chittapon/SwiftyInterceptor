#!/bin/sh

# work directory
cd "$(dirname "$0")"

# When finished, kill the mock server
kill $(< server.pid)

# Remove PID file
rm server.pid