# Swift Skill

Use this skill when writing or modifying Swift code (non-SwiftUI, non-test) in this project. This covers services, models, ViewModels, networking, concurrency, DI, and all pure-Swift logic.

## Architecture: MVVM + Service Layer

- **Views** are pure SwiftUI presentation (covered by a separate skill)
- **ViewModels** are `@MainActor`, use `@Published` + `ObservableObject`, orchestrate state and side effects
- **Services** are protocol-based, registered in `AppServicesRegistrator`, injected via `@ServiceLocator`
- **Models** are plain structs/enums — DTOs for API, domain models for internal use

## Naming Conventions

| Kind | Pattern | Example |
|---|---|---|
| Service protocol | `<Name>Service` | `FlickrService`, `PhotoService` |
| Service implementation | `<Name>ServiceDefault` | `FlickrServiceDefault` |
| ViewModel | `<Name>ViewModel` | `MainListViewModel` |
| DTO | `<Name>DTO` | `PhotoDTO`, `PageDTO` |
| Domain model | `<Name>Model` | `PhotoModel` |
| Error type | `<Name>Error` | `FlickrError`, `HTTPError` |
| Mock (tests only) | `<Name>Mock` | `FlickrServiceMock` |
| Actor | Plain name | `PhotoStorage`, `ImageCacheService` |

### File naming

- One primary type per file
- File name matches the primary type name exactly
- Files grouped by feature, not by type

## Dependency Injection

All services are injected via the `@ServiceLocator` property wrapper. Never instantiate services directly.

### Injecting a service

```swift
// New instance each time (default)
@ServiceLocator var flickrService: FlickrService

// Shared singleton
@ServiceLocator(.singleton) var photoStorage: PhotoStorage
```

### Registering a new service

Register in `AppServicesRegistrator.registerAllServices()`:

```swift
private static func registerMyService() {
    ServiceContainer.register(MyService.self) {
        MyServiceDefault()
    }
}
```

- The factory closure is `@Sendable` and returns a `Sendable` type
- Factories can use `@ServiceLocator` internally to resolve dependencies
- `ServiceContainer` uses `Mutex` internally — factories are retrieved outside the lock before being called to avoid deadlock

### ServiceContainer API

```swift
// Register
ServiceContainer.register(MyService.self) { MyServiceDefault() }

// Resolve (throwing)
let service: MyService = try ServiceContainer.resolve(lifetime: .singleton)

// Resolve (force — only in init where failure is fatal)
let service: MyService = ServiceContainer.forceResole(lifetime: .singleton)
```

Lifetime options: `.singleton` (one shared instance) or `.new` (fresh instance per resolve).

## Defining Services

Every service is a **protocol** with a separate implementation file.

```swift
// MyService.swift
protocol MyService: Sendable {
    func doWork() async throws -> Result
}

// MyServiceDefault.swift
final class MyServiceDefault: MyService {
    func doWork() async throws -> Result {
        // ...
    }
}
```

Rules:
- Protocol must conform to `Sendable`
- Implementation is in a separate file named `<Name>ServiceDefault.swift`
- Register in `AppServicesRegistrator`

## Concurrency Patterns

### @MainActor on ViewModels (mandatory)

```swift
@MainActor
final class MyViewModel: ObservableObject {
    @Published var state: State = .idle
    // All UI state updates happen on main thread
}
```

### Actors for shared mutable state

Use actors when multiple tasks need safe access to mutable state:

```swift
actor PhotoStorage {
    private(set) var photos: [PhotoModel] = []

    func addPhotos(_ photos: [PhotoModel]) {
        self.photos.append(contentsOf: photos)
        notifySubscribers(about: .append(photos))
    }
}
```

### Mutex for thread-safe non-actor classes

Use `Mutex` when actor semantics aren't suitable (e.g., `Sendable` final classes):

```swift
final class PhotoService: Sendable {
    private let loadingTasks: Mutex<[String: Task<UIImage?, Never>]> = .init([:])

    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        if let task = loadingTasks.withLock({ $0[photo.id] }) {
            return await task.value
        }
        // ...
    }
}
```

### Task cancellation — check early and often

```swift
func doWork() async -> Result? {
    if Task.isCancelled { return nil }

    let result = await expensiveOperation()

    if Task.isCancelled { return nil }

    return result
}
```

### Task priorities

- `.high` for user-facing loads: `Task.detached(priority: .high) { ... }`
- `.low` for background housekeeping: `Task(priority: .low) { ... }`

### AsyncStream for reactive updates

```swift
func observeUpdates() -> AsyncStream<UpdateEvent> {
    let uuid = UUID()
    return AsyncStream { continuation in
        continuations[uuid] = continuation
        continuation.onTermination = { @Sendable [weak self] _ in
            Task { await self?.removeContinuation(uuid: uuid) }
        }
    }
}

// Consuming in a ViewModel:
updateStream = Task {
    for await event in await storage.observeUpdates() {
        handleEvent(event)
    }
}
```

### async/await over Combine

Use `async/await` for all new async code. Combine is legacy in this project — only use it when integrating with existing Combine-based APIs (e.g., `CurrentValueSubject` from system frameworks).

## Model Definitions

### DTOs (API layer) — Codable structs

```swift
struct PhotoDTO: Codable, Hashable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String?

    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, title
    }
}
```

- Conform to `Codable` and `Hashable`
- Use `CodingKeys` when needed
- Provide `Equatable` via `id` comparison when identity-based equality is needed
- Add `static var test` and `static func test(id:)` fixtures in the DTO extension for tests

### Domain models — plain structs

```swift
struct PhotoModel: Equatable, Hashable {
    let iterationId = UUID().uuidString
    let photo: PhotoDTO
    var image: UIImage?

    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
        lhs.photo.id == rhs.photo.id
    }
}
```

### State enums in ViewModels

Define state as a nested enum inside the ViewModel:

```swift
extension PhotoListViewModel {
    enum State: Equatable {
        case loading
        case idle
        case allPagesLoaded
        case error(String)
    }
}
```

## Error Handling

### Error type pattern

```swift
enum MyError: Error, Equatable {
    case notFound
    case invalidData
    case serviceError(Int)
}
```

- Conform to `Error` and `Equatable`
- Use associated values for dynamic info (status codes, etc.)
- Can include an `init(code:)` for mapping from API codes

### ErrorMetadata for UI presentation

Wrap errors in `ErrorMetadata` to extract a user-facing message and source:

```swift
let metadata = ErrorMetadata(error: error)
state = .error(metadata.message)

if metadata.source == .authentication {
    errorModel.presentError(metadata.message)
}
```

Sources: `.api`, `.user`, `.authentication`

### ViewModel error handling pattern

```swift
do {
    let result = try await service.doWork()
    state = .idle
} catch {
    let metadata = ErrorMetadata(error: error)
    state = .error(metadata.message)

    if metadata.source == .authentication {
        errorModel.presentError(metadata.message)
    }
}
```

## Networking

### HTTPClient

Generic HTTP client wrapping `URLSessionProtocol`:

```swift
let data = try await httpClient.request(urlRequest)
```

- Throws `HTTPError` for non-2xx responses
- Checks `Task.checkCancellation()` after each await
- Uses `URLSessionProtocol` for testability

### Request building

Use a dedicated `*RequestBuilder` struct with `URLComponents`:

```swift
struct FlickrRequestBuilder {
    let key: String

    func search(query: String, page: Int, perPage: Int, maxUploadDate: Date) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/"
        components.queryItems = [
            .init(name: "method", value: "flickr.photos.search"),
            .init(name: "api_key", value: key),
            // ...
        ]
        return URLRequest(url: components.url!)
    }
}
```

### Response parsing

Parse in the service implementation using `JSONDecoder`:

```swift
let model = try decoder.decode(PhotosResponseDTO.self, from: data)
try checkFlickrResponseStatus(model)
guard let page = model.photos else { throw FlickrError.noData }
return page
```

## Design Patterns

### Decorator pattern (PhotoLoader chain)

Chain decorators implementing the same protocol:

```swift
protocol PhotoLoader: Sendable {
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage?
}

// Assembly in AppServicesRegistrator:
var service: PhotoLoader = PhotoLoaderRaw(flickrService: flickrService)
service = PhotoLoaderCropped(cropSize: AppSettings.croppSize, photoLoader: service)
service = PhotoLoaderCached(photoLoader: service, cacheService: cache)
return PhotoService(photoLoader: service)
```

Each decorator wraps the previous one and adds a concern (caching, cropping, etc.).

### Request deduplication

Use `Mutex<[String: Task<...>]>` to share in-flight requests:

```swift
// Check if already loading
if let task = loadingTasks.withLock({ $0[photo.id] }) {
    return await task.value
}

// Create new task, double-check lock, then await
let newTask = Task<UIImage?, Never> { ... }
let runningTask: Task<UIImage?, Never>? = loadingTasks.withLock {
    if let existing = $0[photo.id] { return existing }
    $0[photo.id] = newTask
    return nil
}
```

### Pagination

Use `FlickrSearchPaginationController` protocol. Extend it — don't bypass it:

```swift
protocol FlickrSearchPaginationController: Sendable {
    var page: Int { get }
    var searchTerm: String { get }
    func isNextPageAvailable() -> Bool
    func loadNextPage() async throws -> [PhotoDTO]
    func resetPages()
    func resetWithNewSearchTerm(_ searchTerm: String)
}
```

The implementation locks `maxUploadDate` on first page load to prevent duplicates across pages.

### Campaign system

Implement the `Campaign` protocol, register with `CampaignStorage`:

```swift
protocol Campaign {
    static var events: Set<String> { get }
    static var priority: Int { get }
    static var name: String { get }
    var state: CurrentValueSubject<CampaignState, Never> { get }
    func canBeShown() -> Bool
    func start(triggeredBy event: String)
    func buildView() -> any View
}
```

`CampaignManager` is an actor. `CampaignLogger` wraps the base logger and forwards events to the campaign manager (composite/decorator pattern).

## Logging

Use `FlickrLogger` protocol, injected via DI:

```swift
protocol FlickrLogger: Sendable {
    func logEvent(_ event: Event)
}

// Event is a simple enum:
enum Event: String {
    case promo, search, special, purchaseCompleted
}
```

## ViewModel Patterns

### Base class with factory method

`PhotoListViewModel` is a base class. Subclasses override `createViewModels(from:)`:

```swift
@MainActor
class PhotoListViewModel: ObservableObject {
    func createViewModels(from models: [PhotoModel]) -> [PhotoItemView.ViewModel] {
        fatalError("createViewModels(from:) has not been implemented")
    }
}

// Subclass:
extension MainListView {
    final class ViewModel: PhotoListViewModel {
        override func createViewModels(from models: [PhotoModel]) -> [PhotoItemView.ViewModel] {
            models.map { PhotoItemView.ViewModel(photo: $0, ...) }
        }
    }
}
```

### Nested ViewModel types

ViewModels for specific views are nested inside the view's extension:

```swift
extension PhotoItemView {
    @MainActor
    final class ViewModel: ObservableObject { ... }
}
```

### Lifecycle

- `onCreate()` / `onCreated()` — called from `.task { }` in the view
- `deinit` — cancel in-flight work

## Common Extensions

### Safe array access

```swift
array[safe: index]  // returns Element?
```

### Collection helpers

```swift
collection.isNotEmpty       // Bool
collection.asyncMap { ... } // async version of map
```

## App Constants

Centralized in `AppSettings`:

```swift
struct AppSettings {
    static let photosPerPage = 10
    static let photoSize = PhotoSize.b
    static var croppSize: CGSize { .init(width: 350, height: 350) }
}
```

## Navigation

Router-based navigation using `Route` and `Route.Screen` enum:

```swift
// Push navigation
let route = Route(screen: .editPhoto(photo), settings: .init(presentationDetents: [.fraction(0.7)]))
navigation = .present(route)
```

To add a new screen:
1. Add case to `Route.Screen`
2. Add view mapping in `Screen+View.swift`
3. Create `<Name>View.swift` + `<Name>ViewModel.swift` in `Screens/<Name>/`

## WatchOS Shared Code

Code shared between iOS and watchOS lives in `WatchOS+iOS/`:
- `HistoryStorage` — UserDefaults-backed, syncs via `WatchConnectivity`
- `WatchConnectionService` — `WCSession` delegate, `@unchecked Sendable`
- Use `#if os(iOS)` / `#if os(watchOS)` for platform-specific branches

## Checklist for New Swift Code

1. Service? Define protocol (`Sendable`), implement in `*Default` file, register in `AppServicesRegistrator`
2. ViewModel? Mark `@MainActor`, use `@Published`, inject via `@ServiceLocator`
3. Async work? Use `async/await`, check `Task.isCancelled`, use appropriate priority
4. Shared mutable state? Use `actor` or `Mutex`
5. Error type? Conform to `Error, Equatable`, add to `ErrorMetadata` if user-facing
6. Model? DTO with `Codable, Hashable`; domain model with `Equatable`
7. Never force-unwrap in production code
8. Image loading always goes through `PhotoService`
9. Pagination always goes through `FlickrSearchPaginationController`
