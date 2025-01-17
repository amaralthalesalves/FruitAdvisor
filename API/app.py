from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
import numpy as np
from PIL import Image
import io
from rembg import remove  
import os

app = Flask(__name__)
model = load_model('Modelo2_Keras_Dropout_BN.h5')
frutas = ['Laranja', 'Maçã']  

def remove_background(img_bytes):
    return remove(img_bytes)

def prepare_image(img_bytes):
    img_no_bg = remove_background(img_bytes)
    img = Image.open(io.BytesIO(img_no_bg)).convert("RGB")
    img = img.resize((100, 100))
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

@app.route('/upload', methods=['POST'])
def upload_image():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        img_bytes = file.read()
        img_array = prepare_image(img_bytes)
        prediction = model.predict(img_array)
        predicted_class = np.argmax(prediction, axis=1)
        predicted_class_name = frutas[predicted_class[0]]
        return jsonify({'predicted_class': predicted_class_name}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)), debug=True)