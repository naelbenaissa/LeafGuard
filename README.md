# LeafGuard

LeafGuard is a mobile application designed to assist with plant care by integrating artificial intelligence to diagnose plant diseases from a simple photo. The application is built to provide an intuitive and accessible experience for gardening enthusiasts by offering tailored and personalized advice.

## Key Features

### AI-Powered Image Analysis
- Take a photo and analyze plants using an AI model.
- Identify diseases in potatoes, peppers, and tomatoes.
- Display results and keep a history of analyses.

### Personalized Care Suggestions
- Recommendations based on AI diagnosis (watering, fertilization, treatments, etc.).
- Access to a knowledge base on plant care.

### Reminder System
- Manage reminders for plant maintenance.
- Notifications for watering, fertilization, and treatments.
- Intuitive interface to schedule reminders.

### Plant Guide
- Search and display detailed information on various plants.
- Favorites system to save plants and analyses.
- Optimized pagination for smooth navigation.

### User Account Management
- Registration and login via Supabase.
- User profile customization.
- Save and manage favorites and reminders.

## Technologies Used

- **Flutter** (Dart) - Mobile development framework.
- **TensorFlow** (Python) - AI model for disease recognition.
- **Supabase** - Database management and authentication.
- **Railway** - Temporary hosting for the AI API.
- **Flutter Local Notifications** - Local notification management.

## Installation and Execution

### Prerequisites
- Flutter installed on your machine ([official guide](https://flutter.dev/docs/get-started/install)).
- A Supabase account for user and data management.
- Proper configuration of Android/iOS permissions for camera and storage.

### Installation
```bash
# Clone the repository
git clone https://github.com/naelbenaissa/leafguard.git
cd leafguard

# Install dependencies
flutter pub get

# Run the application
flutter run
```

## Project Progress

- ✅ Finalized interface and design (Light/Dark Mode, onboarding tutorial, optimized navigation).
- ✅ Implemented image scanning and AI analysis feature.
- ✅ Operational user account and favorites management via Supabase.
- ✅ Reminder system and calendar in place.
- ✅ AI hosted on Google Cloud.
- 🛠️ Searching for a more efficient hosting solution for AI.
- 🔄 Bug fixes and UX improvements underway.

## Remaining Objectives
- [ ] Finalizing local notifications.
- [ ] Final testing and optimization.

## Contributing
Contributions are welcome! If you would like to suggest improvements, open an issue or submit a pull request on [the GitHub repository](https://github.com/naelbenaissa/leafguard).

---

💡 **LeafGuard - Take care of your plants with the help of AI!** 🌿
