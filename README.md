# LeafGuard

**LeafGuard** is a mobile application designed to assist users in plant care by leveraging artificial intelligence to diagnose plant diseases from a simple photo. It delivers a smooth, intuitive experience tailored for gardening enthusiasts, providing actionable and personalized advice.

## Key Features

### AI-Powered Image Analysis

* Capture and analyze photos of your plants using an AI model.
* Identify diseases in potatoes, peppers, and tomatoes.
* Display results and maintain a history of past analyses.

### Personalized Care Suggestions

* Care recommendations based on AI diagnoses (watering, fertilizing, treatments, etc.).
* Access a rich knowledge base for general plant care.

### Reminder System

* Create and manage plant care reminders.
* Receive notifications for watering, fertilizing, and treatments.
* Simple, intuitive scheduling interface.

### Plant Guide

* Search and explore detailed information on various plants.
* Save plants and analyses to your favorites.
* Enjoy smooth navigation with optimized pagination.

### User Account Management

* Register and log in via Supabase.
* Customize your profile.
* Save and manage your favorite plants and reminders.

## Technologies Used

* **Flutter** (Dart) – Cross-platform mobile development.
* **TensorFlow** (Python) – AI model for disease recognition.
* **Supabase** – Backend services for authentication and database.
* **Google Cloud** – Hosting for the AI API.
* **Flutter Local Notifications** – Handling local push notifications.

## Installation and Execution

### Prerequisites

* Flutter installed on your machine ([Official Flutter Guide](https://flutter.dev/docs/get-started/install)).
* A Supabase account for managing users and data.
* Proper configuration of camera and storage permissions for Android/iOS.

### Installation Steps

```bash
# Clone the repository
git clone https://github.com/naelbenaissa/leafguard.git
cd leafguard

# Install dependencies
flutter pub get

# Run the application
flutter run
```

## Project Status

* ✅ Finalized UI and design (Light/Dark mode, onboarding, smooth navigation)
* ✅ AI-powered image analysis fully integrated
* ✅ Supabase-based account and favorite management complete
* ✅ Reminder system and calendar working
* ✅ AI API deployed on Google Cloud
* ✅ Local notifications fully implemented
* ✅ Final testing and optimization complete

## Contributing

We welcome contributions! If you'd like to help improve LeafGuard, feel free to open an issue or submit a pull request on [GitHub](https://github.com/naelbenaissa/leafguard).

---

💡 **LeafGuard – Take care of your plants with the help of AI!** 🌿
