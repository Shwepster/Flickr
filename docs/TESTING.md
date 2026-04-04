# Testing Guide

## Structure

```
FlickrTests/
├── Mocks/               # Mock implementations of service protocols
├── SharedTestData.swift # Shared fixtures (test images, photo lists)
└── *Tests.swift         # Test files per feature/class
FlickrUITests/           # UI automation tests (XCUIApplication)
```

## Running Tests

- Unit tests: `Cmd+U` in Xcode or `xcodebuild test -scheme Flickr`
- UI tests: select `FlickrUITests` scheme

## Test Patterns

### Async Tests

```swift
final class MyServiceTests: XCTestCase {
    func testFetch() async throws {
        let service = MyServiceDefault(dependency: MockDependency())
        let result = try await service.fetch(query: "cats")
        XCTAssertFalse(result.photos.isEmpty)
    }
}
```

### Service Registration Override

Always override DI in `setUp` and reset in `tearDown`:

```swift
override func setUp() {
    super.setUp()
    ServiceContainer.shared.register(FlickrService.self, lifetime: .singleton) { _ in
        FlickrServiceMock()
    }
}

override func tearDown() {
    ServiceContainer.shared.reset()
    super.tearDown()
}
```

### Testing ViewModels

Use Combine to observe `@Published` changes:

```swift
func testSearchUpdatesItems() async throws {
    let viewModel = MainListViewModel()
    viewModel.search(query: "sunset")

    // Wait for async state update
    try await Task.sleep(for: .milliseconds(100))
    XCTAssertFalse(viewModel.items.isEmpty)
}
```

Or use `XCTestExpectation` with Combine:

```swift
let expectation = expectation(description: "items loaded")
var cancellable: AnyCancellable?
cancellable = viewModel.$items
    .dropFirst()
    .sink { items in
        XCTAssertFalse(items.isEmpty)
        expectation.fulfill()
    }
viewModel.load()
await fulfillment(of: [expectation], timeout: 2)
```

## Available Mocks

| Mock | Protocol |
|---|---|
| `FlickrServiceMock` | `FlickrService` |
| `PhotoServiceMock` | `PhotoService` |
| `FlickrSearchPaginationControllerMock` | `FlickrSearchPaginationController` |

Mocks expose `invokedMethod` / `invokedMethodCount` booleans and argument captures for verification.

## Test Fixtures

```swift
// Single test photo
let photo = PhotoDTO.test  // static factory

// List of test photos
let photos = PhotoDTO.testList(count: 5)

// Test image (1x1 pixel PNG)
let image = SharedTestData.testImage
```

## What to Test

**Services:** Focus on state transitions, error propagation, and side effects (cache written/read).

**ViewModels:** Test public state changes (`@Published` properties) in response to method calls. Mock all services.

**Pagination:** Test page increment, reset on new query, boundary conditions (last page).

**Do not test:** SwiftUI view rendering, navigation animations, or anything requiring the full app environment — use UITests for those.

## Adding Tests for a New Feature

1. Create `<Name>Tests.swift` in `FlickrTests/`
2. If your feature uses services, create mocks in `FlickrTests/Mocks/<Name>Mock.swift`
3. Override service registrations in `setUp()`
4. Test the ViewModel state machine, not implementation details
