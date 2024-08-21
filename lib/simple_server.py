from flask import Flask, send_file, jsonify
import os

app = Flask(__name__)

# Configuration settings
app.config['DEBUG'] = True

@app.route('/')
def index():
    return "Welcome to the Flask API server."

@app.route('/test', methods=['GET'])
def test():
    return "Test successful", 200

@app.route('/predict', methods=['POST'])
def predict():
    try:
        return send_file('B:\\Fiverr Projects\\Ocular_App\\lib\\Castes_in_India.pdf', attachment_filename='result.pdf')
    except Exception as e:
        return str(e), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
