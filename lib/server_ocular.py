from flask import Flask, request, send_file, jsonify
import os
from flask_cors import CORS
from werkzeug.utils import secure_filename
from model_utils import load_custom_model, process_image_and_generate_pdf, focal_loss_function
import threading
import logging
from logging.handlers import RotatingFileHandler
from concurrent_log_handler import ConcurrentRotatingFileHandler


app = Flask(__name__)
CORS(app)

# Configuration settings
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
app.config['DEBUG'] = False
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

from werkzeug.middleware.proxy_fix import ProxyFix
app.wsgi_app = ProxyFix(app.wsgi_app)
app.config['PROPAGATE_EXCEPTIONS'] = True

# Setup directories and logging
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOADS_DIR = os.path.join(BASE_DIR, 'uploads')
OUTPUTS_DIR = os.path.join(BASE_DIR, 'outputs')
os.makedirs(UPLOADS_DIR, exist_ok=True)
os.makedirs(OUTPUTS_DIR, exist_ok=True)

# Ensure the logs directory exists
if not os.path.exists('logs'):
    os.makedirs('logs')

if not app.debug:
    # Set up the main rotating file handler for 'server_ocular.log'
    file_handler = RotatingFileHandler('logs/server_ocular.log', maxBytes=10240, backupCount=10)
    file_handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]')
    file_handler.setFormatter(formatter)
    app.logger.addHandler(file_handler)

    # Set up the concurrent rotating file handler for 'flask.log'
    concurrent_handler = ConcurrentRotatingFileHandler('logs/flask.log', maxBytes=10000, backupCount=1)
    concurrent_handler.setLevel(logging.INFO)
    concurrent_handler.setFormatter(formatter)
    app.logger.addHandler(concurrent_handler)

    # Set the overall log level for the application
    app.logger.setLevel(logging.INFO)
    app.logger.info('Server startup')

# Load model
model_path = 'B:\\Fiverr Projects\\Ocular_App\\models\\classifier_DenseNet201\\cv_0.model.best.hdf5'
model = load_custom_model(model_path)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'jpg', 'jpeg', 'png'}

def get_unique_filename(directory, filename):
    base, extension = os.path.splitext(filename)
    counter = 1
    unique_filename = filename
    while os.path.exists(os.path.join(directory, unique_filename)):
        unique_filename = f"{base}_{counter}{extension}"
        counter += 1
    return unique_filename

def process_request_with_timeout(filepath, result):
    try:
        # Assume process_image_and_generate_pdf returns the path to the generated PDF
        output_pdf_path = process_image_and_generate_pdf(filepath, model)
        # Get a unique filename if the file already exists
        final_output_pdf_path = os.path.join(OUTPUTS_DIR, get_unique_filename(OUTPUTS_DIR, os.path.basename(output_pdf_path)))
        os.rename(output_pdf_path, final_output_pdf_path)
        result['output_pdf_path'] = final_output_pdf_path
    except Exception as e:
        result['error'] = str(e)
        app.logger.error(f"Error processing request: {e}")

@app.route('/')
def index():
    app.logger.info("Index endpoint was accessed.")
    return "Welcome to the Flask API server."

@app.route('/test', methods=['GET'])
def test():
    app.logger.info("Test endpoint was accessed.")
    return "Test successful", 200

@app.route('/predict', methods=['POST'])
def predict():
    app.logger.info("Predict endpoint was accessed.")
    if 'file' not in request.files:
        app.logger.warning("No file part in the request.")
        return "No file provided", 400

    file = request.files['file']
    if file.filename == '':
        app.logger.warning("No selected file.")
        return "No file selected", 400
    if not allowed_file(file.filename):
        app.logger.warning("File type not allowed.")
        return "File type not allowed", 400

    filename = secure_filename(file.filename)
    filepath = os.path.join(UPLOADS_DIR, filename)
    
    # Handle existing files
    if os.path.exists(filepath):
        os.remove(filepath)  # Remove existing file to avoid conflicts

    file.save(filepath)
    app.logger.info(f"File saved to {filepath}")

    result = {}
    thread = threading.Thread(target=lambda: process_request_with_timeout(filepath, result))
    thread.start()
    thread.join(timeout=300)

    if thread.is_alive():
        app.logger.error("Request timed out.")
        os.remove(filepath)
        return "Request timed out", 504

    if 'error' in result:
        os.remove(filepath)
        app.logger.error(f"Error during file processing or sending: {result['error']}")
        return result['error'], 500

    try:
        output_pdf_path = result['output_pdf_path']
        app.logger.info(f"Sending file from {output_pdf_path}")
        return send_file(output_pdf_path, as_attachment=True, download_name=os.path.basename(output_pdf_path))
    except Exception as e:
        os.remove(filepath)
        app.logger.error(f"Error during file processing or sending: {e}")
        return str(e), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)
