# Code Conventions

## Naming

| Pattern | Convention | Example |
|---|---|---|
| ViewModels | `<Name>ViewModel` | `MainListViewModel` |
| Services (protocol) | `<Name>Service` | `PhotoService` |
| Services (implementation) | `<Name>ServiceDefault` | `PhotoServiceDefault` |
| Data models | `<Name>DTO` | `PhotoDTO` |
| Mocks | `<Name>Mock` | `FlickrServiceMock` |
| Errors | `<Name>Error` | `FlickrError`, `HTTPError` |

## File Structure

- One primary type per file
- File name matches type name
- Group by feature, not type (e.g., all photo-list files in `Screens/PhotoLists/`)

## Concurrency

```swift
// ViewModels are always @MainActor
@MainActor
final class MyViewModel: ObservableObject {
    @Published var items: [Item] = []

    func load() {
        Task {
            items = try await service.fetch()
        }
    }
}

// Shared mutable state uses Actor
actor MyStore {
    private var data: [String: Item] = [:]
    func set(_ item: Item, for key: String) { data[key] = item }
}

// Thread-safe classes use Mutex (not locks or serial queues)
final class MyService: @unchecked Sendable {
    private let lock = Mutex<[String: Task<Item, Error>]>([:])
}
```

**Rules:**
- `@MainActor` on all ViewModels — no exceptions
- Use `Actor` for shared mutable state in services
- Use `Mutex` when actor semantics aren't possible (`@unchecked Sendable` classes)
- Always check `Task.isCancelled` in long loops
- Prefer `async/await` over Combine for new code

## Error Handling

```swift
// Define errors as enums with cases
enum FlickrError: Error {
    case invalidAPIKey
    case photoNotFound(id: String)
    case networkUnavailable
}

// Wrap errors with metadata for UI presentation
let metadata = ErrorMetadata(error: error, source: .api)
// metadata.title and metadata.message are shown in alerts

// In ViewModels, catch and store for view binding
func load() {
    Task {
        do {
            items = try await service.fetch()
        } catch {
            errorModel = ErrorModel(error)
        }
    }
}
```

**Never** use `fatalError` or force-unwrap (`!`) in production paths.

## Service Usage

```swift
// Inject via property wrapper — never instantiate directly
@ServiceLocator var flickrService: FlickrService
@ServiceLocator var photoService: PhotoService

// NOT this:
let service = FlickrServiceDefault(apiKey: "...")  // ❌
```

## SwiftUI Views

```swift
// Views hold only @StateObject / @ObservedObject / @EnvironmentObject
// No business logic inside body
struct PhotoItemView: View {
    @ObservedObject var viewModel: PhotoItemViewModel

    var body: some View {
        // Layout only
    }
}
```

- Avoid `.onAppear` for data loading when a ViewModel `init` or explicit `load()` can do it
- Navigation is triggered through the `Router`, not `NavigationLink` directly (except when using `navigationDestination`)

## Extensions

- Keep extensions in `Common/Extensions/`
- Name extension files `<TypeName>+<Purpose>.swift` (e.g., `Array+Async.swift`)
- Only extend types you own or add clearly missing conveniences to system types

## Constants

All app-wide constants live in `Common/AppSettings.swift`:

```swift
enum AppSettings {
    static let photosPerPage = 10
    static let photoCropSize = CGSize(width: 350, height: 350)
}
```

All color and gradient definitions live in `Common/AppStyle.swift`.

## Async Patterns

```swift
// Parallel async work
async let a = serviceA.fetch()
async let b = serviceB.fetch()
let (resultA, resultB) = try await (a, b)

// Transform async array
let images = try await photos.asyncMap { photo in
    try await photoService.load(photo)
}

// Reactive stream from actor
for await update in photoStorage.updates {
    apply(update)
}
```
