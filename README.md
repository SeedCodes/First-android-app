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

#### 2. Home Dashboard (Daily Tracking)
- **Arc Header**: Displays arc name and current day progress (e.g., "Day 18 of 75")
- **Dual Progress Rings**: 
  - Outer ring: Overall arc progress (days completed)
  - Inner ring: Daily goals completion percentage
- **Daily Goals Checklist**: Interactive task list with checkboxes
- **Motivational Quotes**: Daily rotating inspirational messages
- **Bottom Navigation**: Quick access to Home, Progress, Journal, and Profile

**Key Features:**
- Beautiful custom-painted circular progress indicators
- Real-time goal tracking with instant visual feedback
- Automatic daily reset for goals
- 30+ motivational quotes that rotate daily
- Smooth animations and transitions
- Completion celebration with visual cues
- Persistent daily progress storage

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
├── main.dart                    # App entry point with routing logic
├── models/
│   ├── arc_data.dart           # Arc data model with progress calculations
│   └── daily_progress.dart     # Daily goal tracking model
├── pages/
│   ├── arc_setup_page.dart     # Onboarding/setup page
│   └── home_dashboard.dart     # Main daily tracking dashboard
└── utils/
    ├── storage_helper.dart     # Local storage utilities
    └── quotes_helper.dart      # Motivational quotes manager
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
- [x] Home Dashboard (Daily Tracking)
- [ ] Challenge Progress (Stats & Streaks)
- [ ] Task Planner
- [ ] Study Tracker
- [ ] Health & Fitness
- [ ] Journal (Reflections & Notes)
- [ ] Profile
- [ ] Settings

## Next Steps

Waiting for page specifications for Challenge Progress or other pages.
