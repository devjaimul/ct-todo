# CT Todo — Flutter Notes App

A modern, beautiful Flutter Todo/Notes application that stores notes in **Firebase Firestore** and provides offline-first caching, pagination, and clean architecture.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)
![GetX](https://img.shields.io/badge/State-GetX-8B5CF6)
![GoRouter](https://img.shields.io/badge/Routing-GoRouter-3B82F6)

---

## 📱 Features

| Feature | Description |
|---|---|
| **Splash Screen** | Animated logo with fade-in + scale effect. Auto-navigates based on auth state. |
| **Authentication** | Email/password Sign In & Sign Up via Firebase Auth with full form validation, password visibility toggle, and AutofillGroup for Google Password Manager. |
| **Home Dashboard** | Stats cards (Total, Pending, In Progress, Cancelled) with gradient design. Paginated todo list with scroll-to-load-more. |
| **CRUD Operations** | Create, Read, Update, Delete todos with title, description, and status dropdown. |
| **Shimmer Loading** | Beautiful shimmer placeholder animations while data loads. |
| **Offline Caching** | Todos cached locally via SharedPreferences. Pending operations synced when back online. |
| **Responsive UI** | Built with `flutter_screenutil` for consistent sizing across devices. |
| **Smooth Animations** | Staggered list animations, page transitions (fade & slide-up). |

---

## 🏗 Architecture

Clean, feature-based architecture:

```
lib/
├── main.dart                              # Entry point, Firebase init
├── firebase_options.dart                  # Firebase config (auto-generated)
├── app/
│   ├── bindings/app_binding.dart          # GetX dependency injection
│   ├── routes/app_router.dart             # GoRouter configuration
│   └── theme/app_theme.dart               # Material 3 light theme
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                # Blue palette & status colors
│   │   ├── app_constants.dart             # Validators, keys, statuses
│   │   └── app_images.dart                # Asset paths
│   ├── services/
│   │   ├── cache_service.dart             # SharedPreferences wrapper
│   │   └── connectivity_service.dart      # Online/offline detection
│   └── widgets/
│       ├── custom_button.dart             # Primary button with loader
│       ├── custom_dialog.dart             # Delete confirmation dialog
│       ├── custom_text_field.dart          # Text field with validation
│       ├── shimmer_loading.dart           # Shimmer placeholders
│       └── toast_helper.dart              # Toast notifications
└── features/
    ├── splash/
    │   └── splash_screen.dart             # Animated splash
    ├── auth/
    │   ├── controller/auth_controller.dart # Firebase Auth logic
    │   └── views/
    │       ├── sign_in_screen.dart         # Login screen
    │       └── sign_up_screen.dart         # Registration screen
    └── home/
        ├── controller/todo_controller.dart # CRUD, cache, pagination
        ├── models/todo_model.dart          # Todo data model
        ├── views/
        │   ├── home_screen.dart            # Dashboard + todo list
        │   └── add_edit_todo_screen.dart   # Add/Edit form
        └── widgets/
            ├── stats_card.dart            # Gradient stat card
            └── todo_card.dart             # Todo list item card
```

---

## 🛠 Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | Cross-platform UI framework |
| [Firebase Auth](https://firebase.google.com/docs/auth) | User authentication |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | Online database |
| [GetX](https://pub.dev/packages/get) | State management & DI |
| [GoRouter](https://pub.dev/packages/go_router) | Declarative routing |
| [ScreenUtil](https://pub.dev/packages/flutter_screenutil) | Responsive design |
| [SharedPreferences](https://pub.dev/packages/shared_preferences) | Local caching |
| [Connectivity Plus](https://pub.dev/packages/connectivity_plus) | Network status |
| [Shimmer](https://pub.dev/packages/shimmer) | Loading placeholders |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Inter font family |

---

## 🔥 Firestore Data Structure

```
users/
  {userId}/
    name: String
    email: String
    createdAt: Timestamp
    todos/
      {todoId}/
        title: String
        description: String
        status: String ("pending" | "in_progress" | "cancelled")
        createdAt: Timestamp
        updatedAt: Timestamp
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x+
- Firebase project with Auth & Firestore enabled
- Android Studio / VS Code

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/devjaimul/ct_todo.git
   cd ct_todo
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - The project is pre-configured with Firebase (`firebase_options.dart`).
   - Ensure Firestore and Authentication (Email/Password) are enabled in your Firebase Console.

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📋 Offline Cache Strategy

1. **Online:** Fetches from Firestore → caches locally in SharedPreferences as JSON.
2. **Offline:** Reads from cache. CRUD operations are saved locally and queued.
3. **Back Online:** Pending operations are automatically synced to Firestore on next fetch.

---

## 🎨 Design Highlights

- **Blue primary color** palette complementing the Caretutors logo
- **Material 3** design system with Google Fonts (Inter)
- **Gradient stat cards** with colored shadows
- **Color-coded status chips** (amber for pending, blue for in-progress, red for cancelled)
- **Staggered animations** on todo cards for smooth list appearance
- **Pull-to-refresh** and **scroll pagination**

---

## 📄 License

This project is for assessment purposes.
