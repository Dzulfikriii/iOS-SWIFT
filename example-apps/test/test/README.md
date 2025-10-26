# test iOS App – Project Structure and File Guide

This document explains the structure of the `test/` folder and how each file works. It also outlines the authentication flow, main navigation, and how to run the app.

## Overview
The app is a SwiftUI iOS application organized into clear layers:
- App entry and root composition
- Core services (business logic)
- Feature modules (Auth, Main)
- Assets and configuration

## Folder Structure
- `App/`
  - `testApp.swift`: The app entry point (`@main`). Sets up a SwiftData `ModelContainer` and hosts `ContentView` inside `WindowGroup`.
  - `ContentView.swift`: Root view that decides between `LoginView` and `MainView` based on authentication state.
- `Core/`
  - `Services/`
    - `AuthenticationManager.swift`: Central auth service; manages login, registration, forgot password, logout, and stores state using `UserDefaults`. Published state drives UI.
- `Features/`
  - `Auth/`
    - `Views/`
      - `LoginView.swift`: Sign-in screen with email/password fields, inline validation, and calls `AuthenticationManager.login(...)`.
      - `RegisterView.swift`: Account creation screen; validates input and triggers `AuthenticationManager.register(...)`.
      - `ForgotPasswordView.swift`: Password reset flow; validates email and simulates reset via `AuthenticationManager.forgotPassword(...)`.
  - `Main/`
    - `Views/`
      - `MainView.swift`: Main UI after login with tab-based navigation (Home, Explore, Notifications, Profile) and supporting widgets.
- `Assets.xcassets/`: Image and color assets (e.g., `AppIcon`, `AccentColor`).
- `Info.plist`: App configuration and metadata.
- `test.entitlements`: Entitlements required by the app (e.g., for capabilities).
- `Item.swift`: Simple SwiftData model used by the template (timestamp demo model).

## Key Files Explained
- `testApp.swift`
  - Initializes SwiftData schema using `Item`.
  - Provides the `ModelContainer` to the app via `.modelContainer(...)`.
  - Hosts `ContentView()` inside the app's `WindowGroup`.

- `ContentView.swift`
  - Owns `@StateObject private var authManager = AuthenticationManager()`.
  - Renders `LoginView` when `authManager.isAuthenticated == false`.
  - Renders `MainView` when `authManager.isAuthenticated == true`.
  - Applies a smooth transition animation when authentication state changes.

- `AuthenticationManager.swift`
  - `@Published var isAuthenticated`, `currentUser`, `isLoading`, `errorMessage` for UI binding.
  - Persists state in `UserDefaults` (`isAuthenticated`, `currentUser`).
  - `login(email:password:)`: Validates fields, simulates API delay, sets `isAuthenticated = true` on success.
  - `register(fullName:email:password:)`: Validates inputs and simulates account creation.
  - `forgotPassword(email:)`: Validates email and simulates a reset request.
  - `logout()`: Clears user data and resets `isAuthenticated`.

- `LoginView.swift`
  - Email and password inputs with inline warnings if fields are empty after submit.
  - Shows granular error messages from `AuthenticationManager` (invalid email, short password, etc.).
  - On successful sign-in, `isAuthenticated` flips to `true` and `ContentView` navigates to `MainView`.

- `RegisterView.swift`
  - Collects full name, email, password; performs basic validation and calls `authManager.register(...)`.
  - Navigational affordances back to login.

- `ForgotPasswordView.swift`
  - Validates email and calls `authManager.forgotPassword(...)`.
  - Displays success message and provides navigation back to login.

- `MainView.swift`
  - Tab-based layout:
    - Home: Quick actions and recent activity.
    - Explore: Category grid and discovery content.
    - Notifications: List of recent notifications.
    - Profile: User info and actions (e.g., logout via `authManager.logout()`).

- `Item.swift`
  - Demo `@Model` for SwiftData with a single `timestamp` field.
  - Included by default from the Xcode template; safe to remove or extend depending on app needs.

## Authentication and Navigation Flow
- On app launch, `ContentView` creates `AuthenticationManager` and checks persisted state.
- `LoginView` uses `authManager.login(...)`.
  - If inputs are invalid, inline field warnings and error messages appear.
  - On success, `isAuthenticated` becomes `true`.
- `ContentView` reacts to `isAuthenticated` and switches to `MainView`.
- From `MainView` (Profile tab), logout triggers `authManager.logout()` which returns to `LoginView`.

## Adding New Features
- Create a new folder under `Features/` for your module.
- Use `Views/`, `ViewModels/`, and `Services/` subfolders to organize UI, state, and logic.
- Expose any shared services via `Core/Services` and inject using `@EnvironmentObject` or dependency injection.

## Running the App
- Quick run on iOS Simulator:
  - `scripts/run-ios-sim.sh` builds, installs, and launches the app.
  - Optional clean build: `scripts/run-ios-sim.sh --clean`
- Auto rebuild on changes:
  - `scripts/watch-ios-sim.sh` watches sources and re-runs on file changes.
  - Override device: `DEVICE_NAME="iPhone 17 Pro Max" scripts/watch-ios-sim.sh`

## Conventions
- SwiftUI for UI, grouped by feature.
- `Core/Services` for business logic and app-wide services.
- Minimal state at the root; pass `AuthenticationManager` via `environmentObject`.
- Use `UserDefaults` for simple persisted auth state (swap to Keychain/server auth for production).

## Notes
- Documentation files have been moved to `docs/` to avoid resource conflicts in the app bundle.
- `test/README.md` is excluded from target membership to keep builds clean.



# DEVICE_NAME="iPhone 17 Pro" CLEAN=1 scripts/watch-ios-sim.sh