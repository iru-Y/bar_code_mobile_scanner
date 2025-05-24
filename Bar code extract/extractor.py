from flask import Flask, request, jsonify
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app) 

PRODUCTS_FILE = 'produtos.txt'

@app.route('/add_barcode', methods=['POST'])
def add_barcode():
    data = request.get_json(silent=True)
    if not data or 'barcode' not in data:
        return jsonify({'error': 'barcode não informado'}), 400

    code = data['barcode']
    if not code:
        return jsonify({'error': 'barcode não pode ser vazio'}), 400
    with open(PRODUCTS_FILE, 'a') as f:
        f.write(code + '\n')

    return jsonify({'status': 'ok', 'barcode': code}), 201

if __name__ == '__main__':
    if not os.path.exists(PRODUCTS_FILE):
        open(PRODUCTS_FILE, 'w').close()
    app.run(host='0.0.0.0', port=5000, debug=True)
