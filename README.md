# BookSwap - Flutter Book Exchange App

A mobile application for swapping books between users, built with Flutter and Firebase.

## Features

- 📚 Browse and search book listings
- 🔄 Request and manage book swaps
- 💬 Real-time chat between users
- 🔔 Push notifications for swap updates
- 👤 User profiles with photo upload
- ✉️ Email verification for security
- 🎨 Beautiful gradient UI design

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │  Pages   │  │ Widgets  │  │ Providers│  │  Theme  │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Models  │  │ Services │  │  Routes  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Firebase │  │Firestore │  │ Storage  │              │
│  │   Auth   │  │ Database │  │          │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
```

## Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** Riverpod (see [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md) for detailed explanation)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Navigation:** Go Router
- **UI:** Material Design with custom gradients

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase account
- iOS Simulator / Android Emulator or physical device

## Build Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd book_swap
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### a. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "BookSwap"
3. Enable Email/Password authentication
4. Create Firestore database in test mode

#### b. Add Firebase Configuration Files

**For iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`

**For Android:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`

**Note:** These files are gitignored for security

#### c. Configure Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Run the App

```bash
# Check for issues
flutter doctor

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

### 5. Code Quality Check

```bash
# Run analyzer
flutter analyze

# Run tests
flutter test
```

## Project Structure

```
lib/
├── core/
│   └── routes/              # App navigation
├── data/
│   └── models/              # Data models
├── presentation/
│   ├── pages/               # App screens
│   ├── providers/           # State management
│   ├── theme/               # Colors, styles
│   └── widgets/             # Reusable components
└── services/                # Firebase services
```

## Key Files

- `lib/main.dart` - App entry point
- `lib/core/routes/app_router.dart` - Navigation configuration
- `lib/presentation/providers/` - Riverpod providers
- `lib/services/` - Firebase service classes
- `firestore.rules` - Database security rules

## Environment Variables

No environment variables needed. Firebase configuration is handled through:
- `ios/Runner/GoogleService-Info.plist` (gitignored)
- `android/app/google-services.json` (gitignored)

## Troubleshooting

### Firebase Connection Issues
- Verify Firebase config files are in correct locations
- Check Firebase project settings match your app bundle ID
- Ensure Firestore security rules allow authenticated access

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### iOS Specific
```bash
cd ios
pod install
cd ..
flutter run
```

## Features Implementation

### Authentication
- Email/Password sign up and sign in
- Email verification with auto-polling
- Password visibility toggle
- Secure session management

### Book Management
- Create, edit, delete book listings
- Image upload to Firebase Storage
- Book condition selection
- Real-time listing updates

### Swap System
- Request book swaps
- Accept/reject swap requests
- Three-state system: pending → accepted/rejected
- Automatic chat creation on acceptance

### Chat
- Real-time messaging
- Unread message badges
- Edit and delete messages
- Message read receipts

### Notifications
- Swap request notifications
- Swap acceptance/rejection alerts
- Unread count badge
- Dedicated notifications page

## Security

- Email verification required
- Firestore security rules enforce authentication
- Sensitive files excluded via .gitignore
- No hardcoded credentials

## Performance

- Real-time Firestore streams for instant updates
- In-memory sorting to avoid composite indexes
- Batch writes for atomic operations
- Retry logic with exponential backoff
- Image caching and optimization

## Code Quality

- Zero analyzer issues
- Null safety enabled
- Comprehensive error handling
- Type-safe throughout
- Clean architecture pattern

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is for educational purposes.

## Contact

For questions or support, please open an issue in the repository.

---

**Built with ❤️ using Flutter and Firebase**
