# Architecture

## Overview

The app follows **MVVM** with a dedicated **Service Layer**. SwiftUI views are pure presentation; all logic lives in ViewModels or Services.

```
View (SwiftUI)
  └── ViewModel (@MainActor, @Published)
        └── Service (Protocol)
              └── Network / Storage / Cache
```

---

## Layers

### Views
- Pure SwiftUI — no business logic, no direct service calls
- Observe ViewModel via `@StateObject` / `@ObservedObject`
- Forced dark mode app-wide (`FlickrApp.swift`)

### ViewModels
- All marked `@MainActor` for thread-safe UI updates
- Expose `@Published` state properties consumed by views
- Trigger async work via `Task { }` blocks initiated from view actions
- Base class `PhotoListViewModel` provides shared pagination behavior

### Services
- Defined as **protocols**; concrete types are `*Default` or named implementations
- Injected via `@ServiceLocator` property wrapper — never instantiated inline
- Registered at app startup in `AppServicesRegistrator`

---

## Dependency Injection

**Files:** `Flickr/Services/ServiceLocator/`

```swift
// Register (AppServicesRegistrator.swift)
container.register(PhotoService.self, lifetime: .singleton) { _ in
    PhotoServiceDefault(...)
}

// Inject (anywhere)
@ServiceLocator var photoService: PhotoService
```

`ServiceContainer` uses `Mutex` for thread-safe concurrent registration and resolution.

**Lifetimes:**
- `.singleton` — one shared instance
- `.new` — new instance on each `resolve()`

---

## Navigation

**Files:** `Flickr/App/Navigation/`

```
AppViewModel (root)
  ├── Router (root navigation stack)
  ├── Router (sheet)
  └── Router (fullscreen)
```

- `Route.Screen` enum — all navigable screens
- `Route.swift` — presentation type (push, sheet, fullscreen)
- `Screen+View.swift` — maps each `Screen` case to its SwiftUI `View`
- Navigate by calling `router.navigate(to: .screen(.detail(photo)))`

---

## Photo Loading Pipeline

**Files:** `Flickr/Services/PhotoService/`

Decorator chain pattern — each loader wraps the next:

```
PhotoLoaderCached
  └── PhotoLoaderCropped (resize to 350×350px)
        └── PhotoLoaderRaw (Flickr API download)
```

`PhotoService` wraps the chain and adds **request deduplication**: concurrent requests for the same photo ID share a single in-flight task (via `Mutex`-protected dictionary).

**Image Cache:** `ImageCacheService` (actor) — file-based disk cache keyed by photo ID.

---

## Photo State Management

**File:** `Flickr/Services/PhotoStorage.swift`

`PhotoStorage` is an **actor** that holds the current list of `PhotoModel` objects and broadcasts changes to all observers via `AsyncStream`.

**Update events:** `.replace`, `.append`, `.update`, `.remove`

ViewModels subscribe by iterating `photoStorage.updates` in a `Task`.

---

## Pagination

**File:** `Flickr/Screens/PhotoLists/FlickrSearchPaginationController.swift`

- Tracks current page, total pages, and API timestamp (prevents result drift between pages)
- `MainListViewModel` calls `paginationController.nextPage()` when the user scrolls near the end
- Resets on new search query

---

## Campaign System

**Files:** `Flickr/Campaign/`

Protocol-based extensible promo system:

```swift
protocol Campaign {
    var priority: Int { get }
    func shouldDisplay(context: CampaignContext) -> Bool
    func view() -> AnyView
}
```

`CampaignManager` holds registered campaigns, evaluates them on events, and picks the highest-priority eligible one. `CampaignViewMediator` bridges the result to the `Router`.

---

## watchOS Integration

**Shared code:** `WatchOS+iOS/HistoryStorage.swift`

- `WatchConnectionService` (iOS) sends data to the watch via WatchConnectivity
- `BackgroundUploadManager` handles background URLSession tasks on watchOS
- The watch app has its own `HistoryView` showing previously viewed photos
