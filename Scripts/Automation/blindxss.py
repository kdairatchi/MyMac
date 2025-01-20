from flask import Flask, request
import logging
import json

app = Flask(__name__)

# Setup logging to capture data in a file called "xss_logs.txt"
logging.basicConfig(filename="xss_logs.txt", level=logging.INFO, format='%(asctime)s - %(message)s')

# Route to capture all GET and POST requests
@app.route("/", methods=["GET", "POST"])
def capture_request():
    # Capture and log request details
    log_data = {
        "method": request.method,
        "url": request.url,
        "headers": dict(request.headers),
        "args": request.args.to_dict(),  # Query parameters
        "form_data": request.form.to_dict(),  # POST form data
        "json_data": request.get_json(silent=True),  # JSON data
        "cookies": request.cookies
    }
    
    # Log the captured data
    logging.info(json.dumps(log_data, indent=2))

    # Respond with a simple message
    return "Request captured", 200

# Optional: Route to test connection
@app.route("/test", methods=["GET"])
def test():
    return "Server is running!", 200

if __name__ == "__main__":
    # Run the Flask server
    app.run(host="0.0.0.0", port=8081)
