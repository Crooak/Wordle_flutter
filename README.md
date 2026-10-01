# Wordle Flutter

A cross-platform clone of the popular **Wordle** word game, built using **Dart** and the **Flutter** framework. Guess the 5-letter word in 6 tries!

## 🚀 Features

- **Cross-Platform Support:** Runs smoothly on Android, iOS, Web, Windows, macOS, and Linux.
- **Classic Wordle Mechanics:** Color-coded tile feedback (Green for correct letter and position, Yellow for correct letter but wrong position, Gray for incorrect letter).
- **Responsive Design:** Optimized UI for both mobile screens and desktop/web browsers.
- **Pure Dart Logic:** Clean and modular architecture for game state and word validation.

## 🛠️ Project Structure

The project follows the standard Flutter application structure:
- `lib/`: Contains the core Dart source code (UI screens, widgets, and game logic).
- `assets/`: Contains dictionaries, words lists, and custom fonts/images.
- Platform folders (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`): Native configurations for each operating system.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev) (Stable channel recommended)
- [Dart SDK](https://dart.dev)
- An IDE like VS Code, Android Studio, or IntelliJ IDEA with Flutter extensions.

## ⚙️ Setup and Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com
   cd Wordle_flutter
   ```

2. **Get dependencies:**
   Fetch all the required packages specified in the `pubspec.yaml` file:
   ```bash
   flutter pub get
   ```

3. **Verify the setup:**
   Ensure your environment is correctly configured and devices are detected:
   ```bash
   flutter doctor
   ```

## 🏃 Running the Application

To run the app in development mode with hot reload:

```bash
flutter run
```

*Note: If you have multiple devices connected, specify the target device using `flutter run -d <device_id>` (e.g., `flutter run -d chrome` or `flutter run -d android`).*

## 📦 Building for Production

To build a release version of the application for your preferred platform:

- **Android (APK):**
  ```bash
  flutter build apk --release
  ```
- **iOS:**
  ```bash
  flutter build ios --release
  ```
- **Web:**
  ```bash
  flutter build web --release
  ```
- **Desktop (Windows/macOS/Linux):**
  ```bash
  flutter build windows
  # or 'macos' / 'linux' depending on your host OS
  ```

## 🤝 Contributing

Contributions are welcome! If you want to improve the game, add new features, or fix bugs:
1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## 📄 License

This project is open-source. Please check the repository settings or contact the maintainer regarding licensing details.
