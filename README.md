# Pay2Win - Salary Savings Competetion App

<div align="center">
    <img src="assets/images/logo.png" alt="Pay2Win Logo" width="200"/>
    <p><i>Track expenses and save more through friendly competition</i></p>
</div>

[![Flutter CI/CD](https://github.com/TheGuyDangerous/pay2win/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/TheGuyDangerous/pay2win/actions/workflows/flutter-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev)
[![Style: Nothing](https://img.shields.io/badge/Style-Nothing_UI-black.svg)](https://nothing.tech)

## Overview

Pay2Win is a mobile application built with Flutter that helps friends track and compare their monthly expenses to encourage better saving habits through friendly competition. The app connects two users in a "duo" relationship and provides a comprehensive dashboard to visualize spending patterns, compare savings, and engage in challenges.

### The Concept

Financial responsibility can be challenging without the right motivation. Pay2Win transforms saving into a competitive and engaging experience by:

- **Comparing Daily Expenses**: See who spends less each day
- **Visualizing Savings Progress**: Track who's saving more over time
- **Creating Financial Challenges**: Challenge your partner to specific saving goals
- **Message-Based Expense Tracking**: Simply type your expenses in chat form

## Features

### 🔐 User Authentication & Profile Management
- Email/password authentication
- User profile customization
- Monthly salary and saving goals setup

### 👥 Duo Formation
- Create or join a saving duo with a unique code
- Permanent partnering for consistent tracking

### 📊 Dashboard Visualization
- Today's spending comparison between duo partners
- Interactive charts for spending patterns
- Savings progress visualization
- Category distribution analysis

### 💰 Expense Tracking
- Manual expense entry with categorization
- Message-based expense tracking with NLP
- Receipt scanning and upload
- Expense history and filtering

### 🏆 Challenges & Gamification
- Create and complete saving challenges
- Achievement system for financial milestones
- Streak tracking for consistent saving

### 💬 Messaging Center
- Built-in chat for discussing finances
- Automatic expense detection from messages
- Motivational messages and saving tips

## Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center"><img src="screenshots/login.png" width="200" alt="Login Screen"/><br/>Login</td>
      <td align="center"><img src="screenshots/dashboard.png" width="200" alt="Dashboard"/><br/>Dashboard</td>
      <td align="center"><img src="screenshots/expense.png" width="200" alt="Add Expense"/><br/>Add Expense</td>
    </tr>
    <tr>
      <td align="center"><img src="screenshots/messages.png" width="200" alt="Messages"/><br/>Messages</td>
      <td align="center"><img src="screenshots/challenges.png" width="200" alt="Challenges"/><br/>Challenges</td>
      <td align="center"><img src="screenshots/reports.png" width="200" alt="Reports"/><br/>Reports</td>
    </tr>
  </table>
</div>

## Design Philosophy

Pay2Win adheres to a minimalist design philosophy inspired by the Nothing design language:

- **Monochromatic Aesthetic**: Black and white with minimal color accents
- **Dot Matrix Patterns**: Distinctive backgrounds and textures
- **Transparent Elements**: Layered UI with subtle transparencies
- **Monospaced Typography**: Consistent, technical font styling throughout

## Tech Stack

### Frontend
- **Framework**: Flutter for cross-platform development
- **State Management**: Provider pattern for reactive state handling
- **UI Components**: Custom widgets following the Nothing design system
- **Animation**: Custom animations for transitions and loading states

### Backend
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore for data storage
- **Storage**: Firebase Storage for receipts and profile pictures
- **Functions**: Firebase Cloud Functions for serverless operations
- **Analytics**: Firebase Analytics for usage insights

## Getting Started

### Prerequisites
- Flutter SDK (>=3.19.0)
- Dart (>=3.2.0)
- Firebase project
- Android Studio / VS Code

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/TheGuyDangerous/pay2win.git
   cd pay2win
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Set up Firebase
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Configure your app with Firebase using FlutterFire CLI
   - Add `.env` file with required environment variables (see `.env.example`)

4. Run the app
   ```bash
   flutter run
   ```

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=your_measurement_id
```

## Architecture

Pay2Win follows a feature-based architecture with clear separation of concerns:

```
lib/
  ├── core/              # Core utilities, widgets, and constants
  ├── features/          # Feature modules
  │    ├── auth/         # Authentication related code
  │    ├── dashboard/    # Dashboard screens and logic
  │    ├── expense/      # Expense tracking functionality
  │    ├── duo/          # Duo management
  │    ├── messaging/    # Messaging center
  │    ├── challenges/   # Challenges and gamification
  │    └── reports/      # Reports and analytics
  ├── models/            # Data models
  ├── services/          # Backend services
  ├── firebase_options.dart  # Firebase configuration
  └── main.dart          # App entry point
```

## Contributing

We welcome contributions to Pay2Win! Please check out our [Contributing Guide](CONTRIBUTING.md) for guidelines on how to proceed.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Privacy Policy

Pay2Win takes your privacy seriously. Please refer to our [Privacy Policy](PRIVACY.md) for information on how we collect, use, and protect your data.

## Acknowledgements

- [Flutter](https://flutter.dev) for the amazing cross-platform framework
- [Firebase](https://firebase.google.com) for backend services
- [Nothing Tech](https://nothing.tech) for design inspiration
- All our contributors and testers

## Contact

For questions, feedback, or support, please [open an issue](https://github.com/TheGuyDangerous/pay2win/issues) or contact the maintainers directly.

---

<div align="center">
    <p>Made with ❤️ by the Pay2Win Team</p>
</div>
