# FocusFlow

FocusFlow is a modern, feature-rich task management application built with **Flutter**. It combines task tracking with a Pomodoro timer to help users stay organized and productive.

The application works seamlessly on **Mobile (Android/iOS)** and **Web**, ensuring your tasks are always accessible.

## Features

- **Task Management**: Create, read, update, and delete tasks with ease.
- **Categorization**: Organize tasks by categories like properties (General, Work, Personal).
- **Prioritization**: Set priority levels (Low, Medium, High) to focus on what matters.
- **Pomodoro Timer**: Integrated timer to boost productivity using the Pomodoro technique.
- **Statistics**: Visual dashboard to track your task completion and productivity stats.
- **Theming**: Beautiful Dark and Light modes.
- **Notifications**: Local notifications for task due dates.
- **Persistent Storage**: Data is saved locally using **Hive**, supporting both Mobile and Web platforms.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart 3](https://dart.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Database**: [Hive](https://docs.hivedb.dev/) (NoSQL, fast, web-compatible)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **UI Components**: Glassmorphism, Animations, Slidable list items.

## Getting Started

Follow these steps to set up the project locally.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE (VS Code or Android Studio) with Flutter extensions.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/adhilkrishnag/focusflow.git
   cd focusflow
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (required for Hive & Riverpod):**
   This project uses code generation. Run the following command to generate the necessary files:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Web Support

The project is fully compatible with Flutter Web. To run on a connected browser (e.g., Chrome):

```bash
flutter run -d chrome
```

## Project Structure

- `lib/models`: Data models (Hive entities).
- `lib/providers`: Riverpod providers for state management.
- `lib/repositories`: Data access layer (Hive Box operations).
- `lib/screens`: UI screens (Home, Add Task, Stats).
- `lib/widgets`: Reusable UI components.
- `test`: Widget and Unit tests.
