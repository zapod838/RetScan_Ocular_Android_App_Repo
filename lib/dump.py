from flask import Flask, request, send_file, jsonify, url_for
import os
from flask_cors import CORS
from werkzeug.utils import secure_filename
from model_utils import load_custom_model, process_image_and_generate_pdf, focal_loss_function
import threading
import logging
from concurrent_log_handler import ConcurrentRotatingFileHandler
from celery import Celery
import uuid
from datetime import datetime, timedelta
from apscheduler.schedulers.background import BackgroundScheduler

app = Flask(__name__)
CORS(app)

# Configuration settings
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
app.config['DEBUG'] = True
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

# Celery configuration
def make_celery(app):
    celery = Celery(app.import_name)
    celery.config_from_object('celeryconfig')
    TaskBase = celery.Task
    class ContextTask(TaskBase):
        abstract = True
        def __call__(self, *args, **kwargs):
            with app.app_context():
                return TaskBase.__call__(self, *args, **kwargs)
    celery.Task = ContextTask
    return celery

celery = make_celery(app)

# Setup directories and logging
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOADS_DIR = os.path.join(BASE_DIR, 'uploads')
OUTPUTS_DIR = os.path.join(BASE_DIR, 'outputs')
os.makedirs(UPLOADS_DIR, exist_ok=True)
os.makedirs(OUTPUTS_DIR, exist_ok=True)

if not os.path.exists('logs'):
    os.makedirs('logs')
handler = ConcurrentRotatingFileHandler('logs/flask.log', maxBytes=10000, backupCount=1)
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]')
handler.setFormatter(formatter)
app.logger.addHandler(handler)

# Load model
model_path = 'B:\\Fiverr Projects\\Ocular_App\\models\\classifier_DenseNet201\\cv_0.model.best.hdf5'
model = load_custom_model(model_path)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'jpg', 'jpeg', 'png'}

@celery.task(bind=True)
def process_file(self, filepath):
    try:
        output_pdf_path = process_image_and_generate_pdf(filepath, model)
        if os.path.exists(output_pdf_path):
            return {'output_pdf_path': output_pdf_path}
        else:
            raise FileNotFoundError(f"PDF not found at: {output_pdf_path}")
    except Exception as e:
        self.retry(exc=e, countdown=60, max_retries=3)
        raise e

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
    unique_filename = f"{uuid.uuid4()}_{filename}"
    filepath = os.path.join(UPLOADS_DIR, unique_filename)
    file.save(filepath)
    app.logger.info(f"File saved to {filepath}")

    # Invoke the Celery task
    task = process_file.apply_async(args=[filepath])
    app.logger.info(f"Task {task.id} started for file {filepath}")
    return jsonify({"task_id": task.id}), 202

@app.route('/status/<task_id>', methods=['GET'])
def task_status(task_id):
    task = process_file.AsyncResult(task_id)
    if task.state == 'PENDING':
        response = {
            'state': task.state,
            'status': 'Pending...'
        }
    elif task.state != 'FAILURE':
        response = {
            'state': task.state,
            'status': task.info.get('status', ''),
            'result': task.info.get('output_pdf_path', '')
        }
        if 'output_pdf_path' in task.info:
            response['result'] = url_for('get_result', task_id=task.id, _external=True)
    else:
        response = {
            'state': task.state,
            'status': str(task.info)  # exception raised
        }
    return jsonify(response)

@app.route('/result/<task_id>', methods=['GET'])
def get_result(task_id):
    task = process_file.AsyncResult(task_id)
    if task.state == 'SUCCESS':
        output_pdf_path = task.info.get('output_pdf_path')
        app.logger.info(f"Fetching result from {output_pdf_path}")
        if output_pdf_path and os.path.exists(output_pdf_path):
            return send_file(output_pdf_path, as_attachment=True, download_name='result.pdf')
        else:
            app.logger.error(f"File {output_pdf_path} does not exist")
    return 'Result not ready', 404

# Cleanup mechanism to delete old files
def delete_old_files():
    now = datetime.now()
    cutoff = now - timedelta(days=1)
    for dirpath, dirnames, filenames in os.walk(OUTPUTS_DIR):
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            if os.path.getmtime(filepath) < cutoff.timestamp():
                os.remove(filepath)
                app.logger.info(f"Deleted old file {filepath}")

scheduler = BackgroundScheduler()
scheduler.add_job(func=delete_old_files, trigger="interval", days=1)
scheduler.start()

if __name__ == '__main__':
    from waitress import serve
    serve(app, host='0.0.0.0', port=5000)
