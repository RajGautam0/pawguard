# PawGuard 🐾 – Dog Protection App

## 📖 Project Overview
PawGuard is a **Final Year Project** that combines **Flutter**, **Python/TensorFlow**, **Flask**, and **MongoDB** to create a cross‑platform dog protection and adoption app.  
It helps pet owners detect skin diseases in dogs using AI, provides first‑aid guidance, and connects users with adoptable dogs.

## 🎯 Objectives
- Detect common dog skin conditions using a trained deep learning model.
- Provide AI‑assisted first‑aid advice (with disclaimers for responsible use).
- Offer an adoption module backed by MongoDB.
- Deliver a polished, demo‑ready Flutter UI across mobile and desktop.

## 🚀 Features
- 🐶 **Disease Detection** – Upload/take a photo → Flask API → TensorFlow model → prediction + confidence.
- 💊 **First‑Aid Suggestions** – Contextual advice for each detected condition.
- 📊 **Adoption Listings** – Real dog profiles stored in MongoDB, fetched via Flask `/dogs` route.
- 🌐 **Cross‑Platform App** – Built with Flutter, runs on Android, iOS, Web, Windows, macOS, Linux.
- 🎨 **Polished UI** – Material 3 theme, camera integration, adoption screen.

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Python (TensorFlow, Flask)
- **Database:** MongoDB
- **Tools:** VS Code, Android Emulator, GitHub

## 📂 Project Structure
pawguard/
├── lib/                # Flutter source code
├── ai_backend/         # AI model + Flask API + MongoDB seed
│   ├── train_model.py  # Model training script
│   ├── app.py          # Flask API (predict + dogs routes)
│   └── seed_db.py      # MongoDB seeding script
├── android/            # Android platform code
├── ios/                # iOS platform code
├── web/                # Web build
├── windows/            # Windows build
├── macos/              # macOS build
├── linux/              # Linux build
└── test/               # Unit & widget tests

Code

## ⚙️ Setup Instructions
### Backend
1. Install dependencies:
   ```bash
   python -m pip install tensorflow flask pymongo pillow scipy matplotlib
Train the model:

bash
python ai_backend/train_model.py
Seed MongoDB with sample dogs:

bash
python ai_backend/seed_db.py
Run Flask API:

bash
python ai_backend/app.py
/predict → POST an image, get disease + confidence + advice.

/dogs → GET adoption listings from MongoDB.

Frontend
Install Flutter dependencies:

bash
flutter pub get
Launch emulator:

bash
flutter emulators --launch Medium_Phone_API_36.1
Run the app:

bash
flutter run
📸 Demo Flow
Open app → Camera → Take/choose photo → Flask API → Disease prediction + advice.

Adoption tab → Fetch dogs from MongoDB → Display profiles.

📜 License
This project is for academic purposes (Final Year Project).
Responsible AI disclaimer: Predictions are for educational/demo use only and not a substitute for veterinary care.

Made with ❤️ by Raj Gautam
