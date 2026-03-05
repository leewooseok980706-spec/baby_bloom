# Project Blueprint: Baby Bloom

## Overview
Baby Bloom is a Flutter application designed for baby growth tracking and parenting support. It integrates Firebase for authentication, data storage, and hosting.

## Project Details
- **Framework:** Flutter
- **State Management:** Provider
- **Backend:** Firebase (Auth, Firestore)
- **Hosting:** Firebase Hosting (Configured)

### Style & Design
- Material 3 Design
- Responsive UI for Web and Mobile
- Custom Color Scheme and Typography (AppTheme)

### Features
- **User Authentication:** 
  - [x] Firebase Anonymous Auth (Initial implementation).
  - [ ] **NEW:** Email/Password Login and Signup.
  - [ ] Auth state persistence and proper routing.
- **User Profile:** Name, Age, Role (Father/Mother), Stage tracking.
- **Home:** Personalized recommended cards based on user stage.
- **Profile:** View and edit user information.
- **Journal & Timeline:** (Under development/placeholder)

## Recent Issues & Resolutions
### 1. Application Execution (Error 400 / Uncaught Error)
- **Problem:** App crashed during initialization or stayed on a white screen.
- **Cause:** Firebase initialization order and Anonymous Auth not enabled in console.
- **Resolution:** 
  - Refactored `main.dart` with a robust `AuthWrapper`.
  - Added explicit `try-catch` and `timeout` during initialization.
  - Provided UI feedback for auth failures.

### 2. Infinite Loading on Info Save
- **Problem:** Saving user info stuck with a spinner.
- **Cause:** Potential Firestore rule/index issues and heavy synchronous `DBSeeder`.
- **Resolution:**
  - Optimized `DBSeeder` to skip if data exists and run in the background.
  - Added a 10-second timeout to the save process.
  - Added detailed diagnostic logging (`developer.log`).

### 3. Missing Profile Edit Feature
- **Problem:** No way to change info after initial input.
- **Resolution:** Added an "Edit" button and BottomSheet to `ProfileScreen`.

## Current Status
- Firebase Hosting is connected: https://baby-bloom-server.web.app
- Code is clean (No `flutter analyze` issues).
- **Manual Action Required:** User must ensure **Anonymous Auth** is enabled and **Firestore Rules** are set in the Firebase Console for full functionality.

### Action Steps
- [x] Configure Firebase Hosting.
- [x] Fix initialization and auth errors.
- [x] Resolve info save hanging issues.
- [x] Implement Profile Edit feature.
- [ ] **Add Login/Signup Screens.**
- [ ] **Update AuthService for Email Auth.**
- [ ] **Refactor AuthWrapper to handle login states.**
- [x] Final code cleanup and analysis.
