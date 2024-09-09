#!/bin/bash

export PYTHONPATH='/tmp/ramdisk/VAP-Concierge/src/'

EXPERIMENT_PIDS=()

# Start the Flask status API in the background
python3 /tmp/ramdisk/VAP-Concierge/src/api_status.py &
API_PID=$!  # Store the PID of the API so we can kill it later

cleanup() {
    for pid in "${EXPERIMENT_PIDS[@]}"; do
        echo "script -- INFO -- Killing process $pid"
        sudo kill -2 "$pid"
        sudo kill -9 "$pid"
    done
	for port in 5030 5001 5002 5003; do
		pid=$(sudo lsof -t -i:$port)
		if [ -n "$pid" ]; then
			echo "script -- INFO -- Killing side process $pid running on port $port"
			sudo kill -9 "$pid"
		fi
	done

    # Notify the status API that the experiment is completed
    curl -X POST "http://localhost:5001/set_status/completed"

    # Wait for client acknowledgment
    echo "Waiting for client acknowledgment..."
    while true; do
        client_ack=$(curl -s http://localhost:5001/status | grep -o '"acknowledged":true')
        if [ "$client_ack" == '"acknowledged":true' ]; then
            echo "Client acknowledgment received. Proceeding with shutdown."
            break
        fi
        sleep 10  # Check every 10 seconds
    done

    # Kill the API process after acknowledgment
    kill $API_PID
    exit 0
}

rm -rf ./app/app*

trap cleanup SIGINT SIGKILL SIGTERM
python runApp.py > /tmp/null &
# python runApp.py &
echo $!
EXPERIMENT_PIDS+=($!)

while true; do
	sleep 1
done
