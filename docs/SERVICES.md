# Services & Dependency Injection

## DI Container

**Files:** `Flickr/Services/ServiceLocator/`

| File | Purpose |
|---|---|
| `ServiceContainer.swift` | Thread-safe registry; `register` + `resolve` |
| `ServiceLocator.swift` | `@ServiceLocator` property wrapper |
| `AppServicesRegistrator.swift` | All production registrations + API key |

### Registering a Service

```swift
// In AppServicesRegistrator.swift
container.register(MyService.self, lifetime: .singleton) { container in
    MyServiceDefault(
        dependency: container.resolve(OtherService.self)
    )
}
```

### Resolving a Service

```swift
// In any ViewModel, Service, or other class
@ServiceLocator var myService: MyService
```

For tests, override registrations in `setUp()` and call `ServiceContainer.shared.reset()` in `tearDown()`.

---

## Registered Services

### FlickrService
- **Protocol:** `FlickrService`
- **Implementation:** `FlickrServiceDefault`
- **Lifetime:** `.singleton`
- **Purpose:** Flickr API search, photo metadata, URL construction
- **Key methods:** `search(query:page:) async throws -> FlickrSearchResult`

### PhotoService
- **Protocol:** `PhotoService`
- **Implementation:** `PhotoServiceDefault`
- **Lifetime:** `.singleton`
- **Purpose:** Load photo `UIImage` via decorator chain; deduplicates in-flight requests
- **Key methods:** `load(_ photo: PhotoDTO) async throws -> UIImage`
- **Chain:** `PhotoLoaderCached → PhotoLoaderCropped → PhotoLoaderRaw`

### ImageCacheService
- **Protocol:** `ImageCacheService`
- **Implementation:** Actor-based default
- **Lifetime:** `.singleton`
- **Purpose:** Disk-based image cache keyed by photo ID
- **Key methods:** `image(for id: String) async -> UIImage?`, `store(_ image: UIImage, for id: String) async`

### PhotoStorage
- **Type:** Actor (`PhotoStorage`)
- **Lifetime:** `.singleton`
- **Purpose:** Central store for the current photo list; broadcasts updates via `AsyncStream`
- **Key methods:** `update(_ event: PhotoStorageEvent) async`, `updates: AsyncStream<PhotoStorageEvent>`

### FlickrSearchPaginationController
- **Lifetime:** `.new` (new instance per use)
- **Purpose:** Manages Flickr search pages + API timestamp for stable pagination
- **Key methods:** `nextPage() -> Int?`, `reset(timestamp:)`

### PurchaseService
- **Protocol:** `PurchaseService`
- **Lifetime:** `.singleton`
- **Purpose:** In-app purchase flow (currently simulated)
- **Key methods:** `purchase() async throws`

### WatchConnectionService
- **Protocol:** `WatchConnectionService`
- **Lifetime:** `.singleton`
- **Purpose:** iOS ↔ watchOS communication via WatchConnectivity

### CampaignManager
- **Type:** `CampaignManager`
- **Lifetime:** `.singleton`
- **Purpose:** Evaluates and dispatches promotional campaigns
- **Key methods:** `register(_ campaign: Campaign)`, `evaluate(event:)`

### FlickrLogger
- **Protocol:** `FlickrLogger`
- **Lifetime:** `.singleton`
- **Purpose:** Event logging abstraction (analytics/crash reporting hook point)

---

## HTTP Client

**File:** `Flickr/Services/Http/HTTPClient.swift`

Generic, protocol-based HTTP client used only by `FlickrServiceDefault`. Not injected via DI — constructed internally.

```swift
let result: FlickrSearchResult = try await httpClient.request(
    FlickrRequest.search(query: query, page: page)
)
```

Throws `HTTPError` for non-2xx responses and decoding failures.

---

## Adding a New Service

1. Create protocol in `Flickr/Services/<Name>/<Name>Service.swift`
2. Create implementation in `Flickr/Services/<Name>/<Name>ServiceDefault.swift`
3. Register in `AppServicesRegistrator.swift`
4. Create `<Name>ServiceMock.swift` in `FlickrTests/Mocks/`
5. Inject anywhere with `@ServiceLocator var myService: MyService`
