# Riverpod Tasks

A Flutter task management app built to demonstrate **Riverpod state management** with multiple provider types, clean architecture, and Material 3 design.

## Features

- **Riverpod providers**: `StateNotifierProvider`, `StateProvider`, `Provider` for derived state
- **CRUD operations**: Create, read, update, and delete tasks
- **Status cycling**: Pending → In Progress → Completed → Pending
- **Filtering**: By status (all, pending, in progress, completed) and category
- **Search**: Real-time search by title or description
- **Statistics**: Visual cards showing Total, Pending, In Progress, and Completed counts
- **Task detail**: Bottom sheet with full task information
- **Due dates**: Optional date picker per task
- **Animations**: Smooth transitions, hover states, and microinteractions
- **Material 3**: Modern design with custom color scheme and gradients

## Provider Types Demonstrated

| Provider | File | Purpose |
|---|---|---|
| `StateNotifierProvider` | `providers/task_provider.dart` | Task CRUD and state management |
| `StateProvider` | `providers/filter_provider.dart` | Filter, category, and search state |
| `Provider` | `providers/task_list_provider.dart` | Derived filtered/sorted task list |

## Architecture

```
lib/
├── main.dart                    # App entry point + theme
├── models/
│   └── task.dart                # Task model with enums
├── providers/
│   ├── task_provider.dart       # TaskNotifier + TaskState
│   ├── filter_provider.dart     # Filter state providers
│   └── task_list_provider.dart  # Derived filtered list
├── screens/
│   ├── home_screen.dart         # Main task list screen
│   └── add_task_screen.dart     # Add new task form
└── widgets/
    ├── task_card.dart           # Task list card + detail sheet
    └── stats_grid.dart          # Statistics cards
```

## Getting Started

```bash
flutter pub get
flutter run
```

Run on web for quick testing:

```bash
flutter run -d chrome
```

## Tests

38 tests covering providers, models, widgets, and integration:

```bash
flutter test
```

- **Unit tests**: TaskNotifier CRUD, filtering, sorting, search
- **Widget tests**: StatsGrid, TaskCard, HomeScreen
- **Integration**: Full app rendering and navigation

## Dependencies

- `flutter_riverpod` — State management
- `flutter` — Framework

## Design

- Custom indigo/purple color scheme
- Gradient stat cards with soft shadows
- Rounded corners (12-16px radius)
- Consistent spacing and typography
- Smooth 300ms animations on status toggle
