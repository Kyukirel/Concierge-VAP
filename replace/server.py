from flask import Flask, request, jsonify
import os
import subprocess
import signal
import argparse

app = Flask(__name__)

# Initialize process variable
process = None

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Control the API status flag.')
parser.add_argument('--api_status', type=str, default='false', help='Set to true to run api_status.py, false otherwise.')
args = parser.parse_args()

@app.route('/start', methods=['GET'])
def index():
    global process
    print("GOT A START REQUEST!!!!", flush=True)
    
    # Change directory and start the experiment script
    os.chdir('/tmp/ramdisk/VAP-Concierge/src/')
    
    # Start the process, passing the api_status argument to the script
    process = subprocess.Popen(["bash", "runExperiment.sh", args.api_status])  # Pass argument to the bash script
    
    print(f"Process started with PID: {process.pid}", flush=True)
    return jsonify({"status": "success", "pid": process.pid})

@app.route('/stop', methods=["GET"])
def stop():
    global process
    print("GOT A STOP REQUEST!!!!", flush=True)
    
    # Check if the process is running
    if process is None:
        return jsonify({"error": "No process running"}), 400

    try:
        # Try to kill the process gracefully
        os.kill(process.pid, signal.SIGTERM)
        os.kill(process.pid, signal.SIGINT)
        process.wait()  # Wait for the process to terminate
        print(f"Process with PID {process.pid} terminated.", flush=True)
        process = None  # Reset the process variable
        
        # Shut down Flask after stopping the process
        shutdown_server()
        
        return jsonify({"status": "Process stopped and server shutting down successfully"})
    except Exception as e:
        return jsonify({"error": f"Failed to stop process: {str(e)}"}), 500

def shutdown_server():
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()

if __name__ == '__main__':
    import logging
    logging.basicConfig(level=logging.INFO)
    
    log = logging.getLogger('werkzeug')
    log.setLevel(logging.ERROR)  # Disable Flask's default logging
    
    app.run(debug=False, host='0.0.0.0', port=6000)
