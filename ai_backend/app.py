from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from pymongo import MongoClient
from bson.json_util import dumps
import numpy as np
import os

app = Flask(__name__)

print("Loading model...")
model = load_model('pawguard_model.h5')

with open('labels.txt', 'r') as f:
    class_names = [line.strip() for line in f.readlines()]
print(f"Model loaded. Classes: {class_names}")

FIRST_AID_ADVICE = {
    'Healthy': "No signs of skin disease detected. Continue regular grooming and monitoring.",
    'Bacterial_dermatosis': "Possible bacterial skin infection. Keep the area clean and dry. Avoid the dog scratching it. Consult a veterinarian for antibiotics if it doesn't improve in 2-3 days.",
    'Fungal_infections': "Possible fungal infection (e.g., ringworm). This can spread to humans and other pets — wash hands after contact. Isolate the dog's bedding. See a vet for antifungal treatment.",
    'Hypersensitivity_allergic_dermatosis': "Possible allergic skin reaction. Try to identify and remove the allergen (food, plants, chemicals). Antihistamines may help short-term. Consult a vet if swelling or breathing issues occur."
}

# --- MongoDB connection ---
mongo_client = MongoClient('mongodb://localhost:27017/')
db = mongo_client['pawguard']
dogs_collection = db['dogs']


@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400

    file = request.files['file']
    filepath = os.path.join('temp_upload.jpg')
    file.save(filepath)

    img = image.load_img(filepath, target_size=(224, 224))
    img_array = image.img_to_array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    prediction = model.predict(img_array)
    predicted_class = class_names[np.argmax(prediction)]
    confidence = float(np.max(prediction))

    os.remove(filepath)

    advice = FIRST_AID_ADVICE.get(predicted_class, "No advice available for this condition. Please consult a veterinarian.")

    return jsonify({
        'disease': predicted_class,
        'confidence': confidence,
        'advice': advice
    })


@app.route('/dogs', methods=['GET'])
def get_dogs():
    dogs = list(dogs_collection.find())
    # Convert MongoDB's ObjectId to a plain string so it can be sent as JSON
    for dog in dogs:
        dog['_id'] = str(dog['_id'])
    return jsonify(dogs)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)