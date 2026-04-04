# Flickr App — Claude Code Guide

iOS photo search app built with SwiftUI, MVVM, and modern Swift concurrency. Integrates the Flickr API to search and browse photos, with a watchOS companion app.

## Key Documentation

- [Architecture](docs/ARCHITECTURE.md) — MVVM layers, navigation, DI container, photo loading pipeline
- [Code Conventions](docs/CONVENTIONS.md) — Naming, concurrency, error handling, async patterns
- [Services & DI](docs/SERVICES.md) — ServiceContainer, ServiceLocator, all registered services
- [Testing Guide](docs/TESTING.md) — Test structure, mocks, async testing patterns

## Project Layout

```
Flickr/
├── App/                  # Entry point, root ViewModel, navigation router
├── Screens/              # SwiftUI views + ViewModels per screen
│   ├── PhotoLists/       # Main list, page view, photo item, pagination
│   ├── EditorView/       # Photo editor screen
│   └── Onboarding/       # Onboarding flow
├── Services/             # All business logic and data services
│   ├── ServiceLocator/   # DI container and property wrapper
│   ├── FlickrService/    # Flickr API client + models
│   ├── PhotoService/     # Image loading decorator chain
│   └── Logger/           # Event logging
├── Campaign/             # Campaign/promo system
└── Common/               # Extensions, styles, app constants
FlickrWatch Watch App/    # watchOS app
WatchOS+iOS/              # Shared code (HistoryStorage)
FlickrTests/              # Unit tests
FlickrUITests/            # UI automation tests
```

## Build & Run

- Open `Flickr.xcodeproj` in Xcode
- No external package dependencies — pure Swift/Foundation
- Targets: `Flickr` (iOS), `FlickrWatch Watch App` (watchOS)
- Minimum iOS 15+, watchOS 9+, Swift 6.0+
- **API key** is hardcoded in `Flickr/Services/ServiceLocator/AppServicesRegistrator.swift`

## Architecture in Brief

**MVVM + Service Layer:**
- Views are pure SwiftUI — no logic
- ViewModels are `@MainActor`, use `@Published` + Combine
- Services are protocol-based, registered in `AppServicesRegistrator`, injected via `@ServiceLocator`

**Navigation:**
- `Router` class drives all navigation via `Route.Screen` enum
- Three router levels: root, sheet, fullscreen

**Thread Safety:**
- Actors for `PhotoStorage`, `ImageCacheService`
- `Mutex` for `ServiceContainer`, `PhotoService` request deduplication
- `@MainActor` on all ViewModels

## Critical Rules

- **Never add UI logic to Views** — all state and side effects belong in ViewModels
- **Always use `@ServiceLocator` for injection** — do not instantiate services directly in ViewModels or Views
- **Register new services in `AppServicesRegistrator`** — both production and test registrations
- **All new services must be protocols** — implementation goes in a separate `*Default` or `*Impl` file
- **Use `@MainActor` on all new ViewModels**
- **Use `async/await` for all new async code** — avoid Combine for new logic; Combine is legacy in this project
- **Never force-unwrap** in production code
- **Image loading always goes through `PhotoService`** — do not use `URLSession` directly for images
- **Pagination** uses `FlickrSearchPaginationController` — extend it, don't bypass it

## Common Tasks

**Add a new screen:**
1. Add a case to `Route.Screen` in `Route.swift`
2. Add the view mapping in `Screen+View.swift`
3. Create `<Name>View.swift` + `<Name>ViewModel.swift` in `Screens/<Name>/`

**Add a new service:**
1. Define protocol in `Services/<Name>/<Name>Service.swift`
2. Implement in `Services/<Name>/<Name>ServiceDefault.swift`
3. Register in `AppServicesRegistrator.swift`
4. Create mock in `FlickrTests/Mocks/`

**Add a campaign:**
1. Implement `Campaign` protocol
2. Register with `CampaignManager` in `AppServicesRegistrator`
