# ThoughtVault

**ThoughtVault** is a beautiful and inspiring quote collection application built with Flutter. It allows users to store, generate, and share quotes with stunning visual customization.

## Features

- 🌟 **Daily Inspiration**: Receive a "Quote of the Day" notification to start your morning right.
- 🎨 **Quote Generator**: Create visually stunning quote cards with custom backgrounds, fonts, and styles.
- 📚 **Collections**: Organize and browse quotes by categories and topics.
- 👤 **User Profiles**: Customize your profile with a display name and avatar.
- 🌙 **Dark Mode**: Fully adaptive, high-contrast dark theme for comfortable reading.
- 🔐 **Secure & Cloud Sync**: Powered by Firebase Authentication and Firestore.

## Privacy & Permissions

ThoughtVault is designed with user privacy as a priority:

- **Photos**: We use the system-integrated **Android Photo Picker**. The app accesses _only_ the specific image you select for your profile. We do not request or rely on broad storage permissions (`READ_MEDIA_IMAGES` is not used).
- **Notifications**: Optional. Used solely to deliver your daily quote.

## Tech Stack

- **Frontend**: Flutter
- **State Management**: Riverpod
- **Backend Services**: Firebase (Auth, Firestore, Storage, Cloud Messaging)
- **Local Features**: Flutter Local Notifications, Shared Preferences

## Getting Started

1. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/quotevault.git
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Configuration**:
   - Ensure you have the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) configured for Firebase.
   - Create a `.env` file if required for environment variables.

4. **Run the app**:
   ```bash
   flutter run
   ```
