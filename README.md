# 🍾 Kaal Spinnex (Neon Spin)

> An immersive, neon-themed multiplayer **Truth or Dare** party game built with **Flutter** and **GetX**.

---

## 🌟 Overview

**Kaal Spinnex** (Neon Spin) reimagines the classic party game *Truth or Dare* for modern mobile devices. Featuring a vibrant cyberpunk neon aesthetic, smooth physics-based bottle spin animations, dynamic multi-player turn tracking, live scoring, and backend-driven challenge prompts.

---

## ✨ Features

- 🍾 **Interactive Bottle Spin Engine**: Smooth, animated bottle spinning mechanism to randomly pick players for Truth or Dare challenges.
- 👥 **Multiplayer Management**: Easily add, edit, and manage players with custom avatars and names.
- ❓ **Dynamic Truth & Dare Prompts**: Integrates with a REST backend to fetch categorized questions in real-time.
- 🏆 **Live Scoreboard**: Track points, completed challenges, and forfeits across all rounds.
- 🎨 **Neon Cyberpunk Aesthetic**: Styled dark mode theme with custom Google Fonts, glowing visuals, and fluid UI transitions.
- 🔊 **Audio Effects**: Integrated sound feedback for bottle spins and game interactions.
- 📱 **Cross-Platform**: Built for iOS, Android, Web, and Desktop using Flutter.

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart ^3.8.1) |
| **State Management & Routing** | [GetX](https://pub.dev/packages/get) (`^4.6.6`) |
| **Networking** | `GetConnect` REST API Client |
| **Audio** | [audioplayers](https://pub.dev/packages/audioplayers) (`^6.0.0`) |
| **Typography & UI** | [google_fonts](https://pub.dev/packages/google_fonts) (`^6.2.1`), Cupertino Icons |
| **Utility** | [url_launcher](https://pub.dev/packages/url_launcher) (`^6.2.6`) |

---

## 📁 Project Architecture

The codebase follows the **GetX Pattern**, enforcing modular separation of concerns between views, logic, bindings, and services.

```text
lib/
├── data/
│   └── models/          # Data models (PlayerModel, QuestionModel)
├── modules/             # Feature Modules (View, Controller, Binding)
│   ├── splash/          # Splash screen & onboarding
│   ├── home/            # Player management & game setup
│   ├── game/            # Interactive bottle spin arena
│   ├── challenge/       # Truth or Dare prompt screen
│   └── scoreboard/      # Score tracking & leaderboard
├── routes/              # App navigation & route definitions
├── services/            # API providers (QuestionProvider / REST Integration)
├── theme/               # Neon dark theme configuration & color tokens
└── main.dart            # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed on your machine:

- **Flutter SDK**: `>= 3.8.1`
- **Dart SDK**: Installed with Flutter
- An IDE such as **VS Code** or **Android Studio** with Flutter & Dart plugins installed
- An Android Emulator, iOS Simulator, or connected physical device

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/kaal_spinnex.git
   cd kaal_spinnex
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🌐 API & Backend Integration

The app connects to a RESTful API backend (`https://spinnex-backend-dev.onrender.com/api`) to fetch Truth & Dare questions based on selected categories. 

You can configure the backend base URL in `lib/services/api_service.dart`:

```dart
baseUrl = 'https://spinnex-backend-dev.onrender.com/api';
```

---

## 🤝 Contributing

Contributions are welcome! If you'd like to improve the game, feel free to fork the repository, make your updates, and submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AwesomeFeature`)
3. Commit your Changes (`git commit -m 'Add some AwesomeFeature'`)
4. Push to the Branch (`git checkout -b feature/AwesomeFeature`)
5. Open a Pull Request

---

## 📄 License

This project is released under the [MIT License](LICENSE) (or proprietary - update as needed).
