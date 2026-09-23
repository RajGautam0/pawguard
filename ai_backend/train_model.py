import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model
import os

# --- CONFIGURATION ---
# This points to where your images are. 
# Based on your screenshot, they are inside the 'Dogs' folder.
DATASET_PATH = 'dataset/Dogs' 
IMG_SIZE = (224, 224)  # MobileNetV2 expects 224x224 images
BATCH_SIZE = 32        # Number of images to process at once

print(f"Checking for images in: {os.path.abspath(DATASET_PATH)}")

# --- STEP 1: LOAD AND PREPARE DATA ---
# We use ImageDataGenerator to load images and "augment" them (flip/rotate) 
# so the AI learns better.
train_datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.2,
    rotation_range=30,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.15,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest'
)

print("Loading Training Data...")
train_generator = train_datagen.flow_from_directory(
    DATASET_PATH,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='training'
)

print("Loading Validation Data...")
validation_generator = train_datagen.flow_from_directory(
    DATASET_PATH,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='validation'
)

# Check if data was found
if train_generator.samples == 0:
    print("\n❌ ERROR: No images found! Check your folder structure.")
    print(f"Looking for folders inside: {os.path.abspath(DATASET_PATH)}")
    exit()

# Save the class names (e.g., Healthy, Mange) so we know what is what later
class_names = list(train_generator.class_indices.keys())
print(f"\n✅ Classes found: {class_names}")
with open('labels.txt', 'w') as f:
    for name in class_names:
        f.write(name + '\n')

# --- STEP 2: BUILD THE MODEL (Transfer Learning) ---
print("\nDownloading MobileNetV2 (The Brain)...")
# We load MobileNetV2 but cut off the "top" (the head).
base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))

# We freeze the base model so we don't destroy its pre-trained knowledge
base_model.trainable = False

# We add our own "Head" to learn YOUR specific diseases
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(128, activation='relu')(x)
x = tf.keras.layers.Dropout(0.5)(x)  # Randomly "forget" 50% of neurons each step to prevent memorizing
predictions = Dense(len(class_names), activation='softmax')(x)
model = Model(inputs=base_model.input, outputs=predictions)

# Compile the model
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# --- STEP 3: TRAIN THE MODEL ---
print("\n🚀 Starting Training... (This will take a few minutes)")
EPOCHS = 10 # How many times to read the whole dataset

checkpoint = tf.keras.callbacks.ModelCheckpoint(
    'pawguard_model.h5',
    monitor='val_accuracy',
    save_best_only=True,
    mode='max',
    verbose=1
)

checkpoint = tf.keras.callbacks.ModelCheckpoint(
    'pawguard_model.h5',
    monitor='val_accuracy',
    save_best_only=True,
    mode='max',
    verbose=1
)

history = model.fit(
    train_generator,
    epochs=EPOCHS,
    validation_data=validation_generator,
    callbacks=[checkpoint]
)

# --- STEP 4: SAVE THE BRAIN ---
print("\n✅ SUCCESS! Best model was automatically saved as 'pawguard_model.h5' during training.")