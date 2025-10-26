# Architecture Overview

This document outlines the app’s high-level architecture, focusing on state management, view composition, and the authentication flow. It complements `test/README.md` by visualizing how the pieces fit together and where to extend the app.

## App Layers

- SwiftUI App Entry: `test/App/testApp.swift` instantiates `ContentView` and injects shared objects (e.g., `AuthenticationManager`).
- State Management: `Core/Services/AuthenticationManager.swift` as an `ObservableObject` controlling `@Published isAuthenticated` and `errorMessage`.
- Features:
  - Auth Views: `Features/Auth/` (`LoginView`, `RegisterView`, `ForgotPasswordView`)
  - Main Views: `Features/Main/` (`MainView` and related UI)
- App Shell: `App/ContentView.swift` switches between Auth and Main based on `isAuthenticated`.
- Model: `Item.swift` as a simple data type used by the Main feature.

---

## Authentication State Flow

```text
+-------------------+            +----------------------+            +-------------------+
|   LoginView       |  Sign In   | AuthenticationManager |  success   |   ContentView     |
| (email, password) |----------->|  .login(email, pass)  |----------->|  isAuthenticated  |
|  onTap Sign In    |            |  validates input      |            |    toggles true   |
+-------------------+            +----------------------+            +-------------------+
                                                                       |
                                                                       | shows MainView
                                                                       v
                                                              +-------------------+
                                                              |     MainView      |
                                                              |  logged-in UI     |
                                                              +-------------------+
                                                                       |
                                                                       | logout
                                                                       v
                                                              +-------------------+
                                                              | AuthenticationMgr |
                                                              | set isAuth = false|
                                                              +-------------------+
                                                                       |
                                                                       | isAuthenticated false
                                                                       v
                                                              +-------------------+
                                                              |    ContentView    |
                                                              | shows LoginView   |
                                                              +-------------------+
```

- Input Validation: `AuthenticationManager.login(...)` checks empty fields and updates `errorMessage` on failure.
- State Transition: On success, `isAuthenticated = true` triggers UI to show `MainView`. On logout, `isAuthenticated = false` returns to `LoginView`.
- Error Reporting: `LoginView` reads `AuthenticationManager.errorMessage` or shows inline warnings when fields are empty.

---

## View Composition

```text
+-------------------+
|    testApp        |
|  Entry Point      |
+---------+---------+
          |
          v
+-------------------+
|   ContentView     |
| Reads isAuth      |
+----+----------+---+
     |          |
     |true      |false
     v          v
+---------+   +------------------+
| MainView|   |    LoginView     |
| Logged  |   |  Auth UI         |
| In UI   |   |  Register/Forgot |
+---------+   +------------------+
```

- `ContentView` acts as the app shell, choosing which feature surface to display.
- `MainView` composes your primary logged-in experience (e.g., list, tabs, actions).
- `LoginView` provides entry points to register and password recovery.

---

## Key Interactions

- Sign In:
  - `LoginView` -> `AuthenticationManager.login(email, password)`
  - On success: `isAuthenticated = true` -> `ContentView` shows `MainView`.
  - On validation failure: inline warnings + `errorMessage` for granular feedback.
- Logout:
  - Initiated from `MainView` (or any logged-in page) -> set `isAuthenticated = false`.
  - `ContentView` updates to show `LoginView`.

---

## Extensibility Guide

- Add a new feature:
  - Create `Features/<FeatureName>/` and place SwiftUI Views, ViewModels, and helpers inside.
  - If the feature is accessible only when logged in, mount it within `MainView` (or a new container view).
  - Shared services go into `Core/Services/` and are injected via environment or observable objects.
- Add a new service:
  - Place in `Core/Services/`, keeping it focused and testable.
  - Use protocols for dependency injection when appropriate.
- Navigation patterns:
  - Prefer a single app shell (`ContentView`) that responds to top-level state changes.
  - Use environment objects or bindings for scoped state.

---

## Testing and CI Hooks (optional)

- Unit Tests:
  - Validate `AuthenticationManager` state transitions and error messages.
- UI Tests:
  - Assert that empty fields show warnings; a valid sign-in navigates to `MainView`.
- CI:
  - Use clean builds and avoid bundling docs into app resources to prevent duplicate output conflicts.

---

## References

- `test/README.md` — detailed file-by-file documentation
- `Core/Services/AuthenticationManager.swift` — source of truth for auth state
- `App/ContentView.swift` — app shell and navigation logic
- `Features/Auth/*` — auth-related views (login/register/forgot)
- `Features/Main/*` — main logged-in experience



