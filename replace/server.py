from flask import Flask, request
import os
import subprocess
import signal
import argparse

app = Flask(__name__)
jupyter_ip = None  # Global variable to hold the Jupyter notebook's IP

@app.route('/start', methods=['GET'])
def index():
    global process
    print("GOT A START REQUEST!!!!")
    os.chdir('/tmp/ramdisk/VAP-Concierge/src/')

    # Pass the IP to the bash script if provided, else handle for local
    if jupyter_ip:
        process = subprocess.Popen(["bash", "runExperiment.sh", jupyter_ip])
    else:
        process = subprocess.Popen(["bash", "runExperiment.sh"])

    return "success"

@app.route('/stop', methods=["GET"])
def stop():
    print("GOT A STOP REQUEST!!!!")
    global process
    os.kill(process.pid, signal.SIGTERM)
    os.kill(process.pid, signal.SIGINT)
    os.chdir('/tmp/ramdisk/VAP-Concierge/src/')
    return "Success"

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Run Flask server to manage experiments.")
    parser.add_argument('--jupyter_ip', type=str, help="The IP address of the Jupyter notebook to notify.", default=None)
    args = parser.parse_args()

    # Store the IP passed via argument, or None if not provided
    jupyter_ip = args.jupyter_ip
    if jupyter_ip:
        print(f"Using Jupyter IP: {jupyter_ip}")
    else:
        print("No Jupyter IP provided, running in local mode.")

    app.run(debug=False, host='0.0.0.0', port=6000)
