# The Winter Arc

A productivity and self-growth app built with Flutter to help users track their Winter Arc challenge goals, study sessions, fitness activities, and personal reflections in a gamified way.

## Features

### ✅ Completed Pages

#### 1. Arc Setup (Onboarding)
- **Duration Selection**: Choose challenge duration between 70-90 days with an interactive slider
- **Goal Selection**: Pick 3-5 goals from predefined templates or add custom goals
- **Arc Naming**: Give your challenge a personalized name
- **Data Persistence**: All setup data is saved using SharedPreferences

**Key Features:**
- Modern, dark-themed UI with clean Material Design
- Interactive slider for duration selection
- Chip-based goal selection with visual feedback
- Custom goal input with validation
- Real-time goal counter (3-5 goals required)
- Persistent storage for arc configuration

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── arc_data.dart        # Arc data model
├── pages/
│   └── arc_setup_page.dart  # Onboarding page
└── utils/
    └── storage_helper.dart  # Local storage utilities
```

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Storage**: SharedPreferences
- **Design**: Material Design with custom dark theme

## Color Scheme

- **Background**: `#0A0E21` (Dark Navy)
- **Surface**: `#1D1E33` (Card Background)
- **Primary**: `#4A90E2` (Blue)
- **Secondary**: `#50C878` (Emerald Green)

## Development Progress

- [x] Arc Setup (Onboarding) Page
- [ ] Home Dashboard
- [ ] Challenge Progress
- [ ] Task Planner
- [ ] Study Tracker
- [ ] Health & Fitness
- [ ] Journal
- [ ] Profile
- [ ] Settings

## Next Steps

Waiting for page specifications for the Home Dashboard.
