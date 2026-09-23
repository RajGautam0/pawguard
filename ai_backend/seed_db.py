from pymongo import MongoClient

# Connect to local MongoDB
client = MongoClient('mongodb://localhost:27017/')
db = client['pawguard']
dogs_collection = db['dogs']

# Clear existing data (so re-running this script doesn't create duplicates)
dogs_collection.delete_many({})

# Sample dog data
sample_dogs = [
    {
        "name": "Bhunte",
        "age": "2 Years",
        "gender": "Male",
        "status": "Available",
        "description": "A friendly and playful dog, great with kids.",
        "color": "brown"
    },
    {
        "name": "Kale",
        "age": "8 Months",
        "gender": "Male",
        "status": "Available",
        "description": "A young energetic pup, loves walks and toys.",
        "color": "black"
    },
    {
        "name": "Khaire",
        "age": "3 Years",
        "gender": "Female",
        "status": "Available",
        "description": "Calm and gentle, good companion for a quiet home.",
        "color": "orange"
    },
    {
        "name": "Sundar",
        "age": "1 Year",
        "gender": "Male",
        "status": "Available",
        "description": "Rescued from a road injury, now fully recovered and healthy.",
        "color": "grey"
    }
]

result = dogs_collection.insert_many(sample_dogs)
print(f"✅ Inserted {len(result.inserted_ids)} dogs into the database.")

# Verify by printing what's in the database
print("\nCurrent dogs in database:")
for dog in dogs_collection.find():
    print(f"- {dog['name']} ({dog['age']}, {dog['gender']})")