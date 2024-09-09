#!/bin/bash

export PYTHONPATH='/tmp/ramdisk/VAP-Concierge/src/'

EXPERIMENT_PIDS=()
jupyter_ip=$1  # Capture the IP address passed as the first argument

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

    # Handle the case where the Jupyter IP is not provided
    if [ -z "$jupyter_ip" ]; then
        echo "No Jupyter IP provided, skipping notification."
    else
        # Define the Flask API endpoint for notifying experiment completion (use the Jupyter IP)
        ENDPOINT_URL="http://$jupyter_ip:5000/experiment_finished"

        # Send a message to the endpoint with experiment status
        curl -X POST -H "Content-Type: application/json" -d '{"status": "completed"}' $ENDPOINT_URL
    fi

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
