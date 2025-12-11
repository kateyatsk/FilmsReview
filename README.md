# 🎬 FilmsReview

FilmsReview is an iOS application for movie enthusiasts that allows users to search for movies, view detailed information, read and leave reviews, and manage a list of favorites.

![Swift](https://img.shields.io/badge/Swift-5.0-orange?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-iOS_15.0+-lightgrey?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-VIP_(Clean_Swift)-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

## 📱 Features

The application provides a complete user journey from registration to content interaction:

* 🔐 Authentication:
    * Sign Up and Login via Email (Firebase Auth).
    * Password recovery and email verification.
    * Interest selection upon first login.
* 🏠 Home Screen:
    * Feed of popular movies and recommendations.
    * Horizontal and vertical content lists.
* 🔍 Search:
    * Search for movies and TV shows via TMDB API.
    * Filtering and categories.
* 📄 Movie Details:
    * Detailed information (posters, description, rating).
    * List of episodes and seasons (for TV shows).
    * User reviews and cast members.
* ❤️ Favorites:
    * Save liked movies and TV shows.
    * Categorization (Movies, TV Shows, etc.).
* 👤 User Profile:
    * Profile editing.
    * Avatar upload (via Cloudinary).

---

## 🛠 Tech Stack

| Category | Technologies & Libraries |
|-----------|-------------------------|
| Language | Swift 5 |
| UI | UIKit (Programmatic UI + XIBs), Custom Fonts (Montserrat) |
| Architecture | VIP (View-Interactor-Presenter) + Router + Worker |
| Networking | Native URLSession, TMDB API Integration |
| Backend / BaaS | Firebase (Auth, Firestore) |
| Media | Cloudinary (Image hosting) |
| DI | Custom Dependency Injection Container |
| Testing | XCTest (Unit Tests), XCUITest (UI Tests) |
| Package Manager | Swift Package Manager (SPM) |

---

## 🏗 Architecture

The project is built using the Clean Swift (VIP) architectural pattern, ensuring modularity, testability, and separation of concerns.

Each scene (screen) consists of the following components:
* View (ViewController): Responsible for displaying the UI and passing user actions to the Interactor.
* Interactor: Contains business logic. Communicates with the Worker to fetch data and passes results to the Presenter.
* Presenter: Formats the data received from the Interactor and prepares it for display in the View.
* Router: Handles navigation and data passing between screens.
* Worker: Helper class for handling API calls and database operations.

---

## 🧪 Testing

The project has good test coverage.

* Unit Tests: Cover Interactors, Presenters, and Workers (focusing on authentication logic and validation).
* UI Tests: Verify main user flows (Login, Sign Up, Onboarding).

---

## 📂 Project Structure

```text
FilmsReview
├── App                  # AppDelegate, SceneDelegate, AppRouter
├── Core                 # Shared models, extensions, networking, DI
│   ├── DI               # Assemblies and Container
│   ├── Network          # API Client, Firebase, Cloudinary
│   ├── UI               # Design System (Fonts, Colors, Components)
│   └── Models           # Shared data models
├── Resourses            # Assets, fonts, animations
├── Scenes               # App screens (VIP modules)
│   ├── Authentication   # Login, SignUp, Password Recovery
│   ├── Onboarding       # Welcome screens
│   └── MainTabBar       # Main tabs (Home, Search, Favorite, Profile)
└── FilmsReviewTests     # Unit Tests
