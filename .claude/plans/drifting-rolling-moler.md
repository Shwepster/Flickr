# Plan: Comprehensive UI Test Suite for Flickr iOS App

## Context

The Flickr iOS app currently has **zero real UI tests** — only the Xcode-generated templates at `FlickrUITests/FlickrUITests.swift` and `FlickrUITests/FlickrUITestsLaunchTests.swift`. There are also **no accessibility identifiers** on interactive views, and **no test hooks** in the app (no launch arguments, no mock service injection), so the app always hits the real Flickr API via a hardcoded key in `Flickr/Services/ServiceLocator/AppServicesRegistrator.swift:46`.

The goal is to build a UI test suite that covers the main user flows — search, photo list interactions, detail page view, editor, and search history — that is **deterministic, fast, and stable**. To achieve that, the plan makes minimal hooks in production code (launch-argument-driven mock service and accessibility identifiers), then writes XCUITest test classes against those hooks.

**Decisions already made with the user:**
- Full approach: launch-argument test hooks + mock service + accessibility identifiers
- **Skip** onboarding tests (onboarding is disabled by default — `FlickrApp.swift:12` initializes with `showOnboarding: false`)
- Cover all core flows: search, list, detail, editor, history, launch smoke
- Tests run **only on iPhone 15 Pro** (single simulator destination)

---

## Architecture

### Production hooks (`#if DEBUG`-gated)

**1. Launch argument detection — `Flickr/App/UITestingSupport.swift` (NEW, DEBUG-only)**

A small file wrapped in `#if DEBUG` that:
- Checks `ProcessInfo.processInfo.arguments` for `-ui-testing`
- When present, before `AppServicesRegistrator.registerAllServices()`:
  - Registers a `FlickrServiceUITestStub` as the `FlickrService` implementation
  - Clears `HistoryStorage`, `PhotoStorage`, and `ImageCacheService`
  - Reads optional extra args:
    - `-ui-testing-empty-results` → stub returns an empty `PageDTO`
    - `-ui-testing-force-onboarding` → reserved, unused (onboarding skipped per decision)

**2. Stub FlickrService — inside the same `UITestingSupport.swift`**

```swift
final class FlickrServiceUITestStub: FlickrService, @unchecked Sendable {
    var returnEmpty = false
    // Returns 20 deterministic photos per page, 3 pages total, titles "Test Photo 1"..."Test Photo 60"
    func search(for query: String, page: Int, perPage: Int, maxUploadDate: Date) async throws -> PageDTO
    // Returns a tiny embedded PNG (4x4 solid color) so images actually render
    func loadImageData(for photo: PhotoDTO, size: PhotoSize) async throws -> Data
}
```

The stub is **inside the app target** (not the test target) because XCUITest launches the app as a separate process — the test target cannot inject anything at runtime.

**3. FlickrApp entry point — modify `Flickr/App/FlickrApp.swift:14-17`**

Change `init()` to call `UITestingSupport.applyIfNeeded()` *before* `AppServicesRegistrator.registerAllServices()`. The helper is a no-op in release builds (`#if DEBUG` wrapping), zero impact on shipping code.

### Accessibility identifiers

**New file — `Flickr/Common/AccessibilityIdentifiers.swift`** (added to **both** `Flickr` and `FlickrUITests` targets; no dependencies, so trivially sharable).

```swift
enum A11y {
    enum Main {
        static let navTitle = "main.navTitle"
        static let toolbarSend = "main.toolbar.send"
        static let toolbarToggleView = "main.toolbar.toggleView"
    }
    enum Search {
        static let field = "search.field"
        static let historyList = "search.history.list"
        static let historyEmpty = "search.history.empty"
        static let historyClear = "search.history.clear"
        static func historyItem(_ text: String) -> String { "search.history.item.\(text)" }
        static func historyDelete(_ text: String) -> String { "search.history.delete.\(text)" }
    }
    enum PhotoList {
        static let list = "photoList.list"
        static let loading = "photoList.loading"
        static let error = "photoList.error"
        static func item(_ id: String) -> String { "photo.item.\(id)" }
        static func deleteButton(_ id: String) -> String { "photo.item.delete.\(id)" }
    }
    enum PageView {
        static let scroll = "pageView.scroll"
        static func page(_ id: String) -> String { "pageView.page.\(id)" }
    }
    enum Editor {
        static let image = "editor.image"
        static let slider = "editor.slider"
        static let angleValue = "editor.angleValue"
        static let save = "editor.save"
    }
}
```

### Files to modify — add `.accessibilityIdentifier(...)` calls

| File | Element | Identifier |
|---|---|---|
| `Flickr/Screens/PhotoLists/SearchView/SearchableMainListView.swift:20` | `.navigationTitle("Flickr")` → also set `.accessibilityIdentifier(A11y.Main.navTitle)` on `MainListView` | `main.navTitle` |
| `Flickr/Screens/PhotoLists/SearchView/SearchableMainListView.swift:44` | `VStack` of history list | `A11y.Search.historyList` |
| `Flickr/Screens/PhotoLists/SearchView/SearchableMainListView.swift:64-73` | Clear history Button | `A11y.Search.historyClear` |
| `Flickr/Screens/PhotoLists/SearchView/SearchableMainListView.swift:76-82` | Empty history Text | `A11y.Search.historyEmpty` |
| `Flickr/Screens/PhotoLists/SearchView/SearchableMainListView.swift:85-105` | `HStack` historyView → container + inner delete Button | `A11y.Search.historyItem(text)` and `A11y.Search.historyDelete(text)` |
| `Flickr/Screens/PhotoLists/MainList/MainListView.swift:16-32` | Both toolbar Buttons | `A11y.Main.toolbarSend`, `A11y.Main.toolbarToggleView` |
| `Flickr/Screens/PhotoLists/MainList/ListView.swift:17` | `List` | `A11y.PhotoList.list` |
| `Flickr/Screens/PhotoLists/MainList/ListView.swift:43-46` | Progress view | `A11y.PhotoList.loading` |
| `Flickr/Screens/PhotoLists/MainList/ListView.swift:71-88` | errorView container | `A11y.PhotoList.error` |
| `Flickr/Screens/PhotoLists/MainList/Item/PhotoItemView.swift:14-32` | root `ZStack` | `A11y.PhotoList.item(viewModel.id)` |
| `Flickr/Screens/PhotoLists/MainList/Item/PhotoItemView.swift:42-49` | trash Button | `A11y.PhotoList.deleteButton(viewModel.id)` |
| `Flickr/Screens/PhotoLists/PageView/PageView.swift` | ScrollView + each page | `A11y.PageView.scroll`, `A11y.PageView.page(id)` |
| `Flickr/Screens/EditorView/EditorView.swift:31-42` | editor image overlay | `A11y.Editor.image` |
| `Flickr/Screens/EditorView/EditorView.swift:58-65` | Slider + value Text | `A11y.Editor.slider`, `A11y.Editor.angleValue` |
| `Flickr/Screens/EditorView/EditorView.swift:45-55` | Save Button | `A11y.Editor.save` |

Note: SwiftUI `.searchable` creates the search field automatically. XCUITest already exposes it via `app.searchFields.firstMatch` — no identifier needed there. We keep `A11y.Search.field` for clarity but query via the built-in collection.

---

## Test file structure

All new files under `FlickrUITests/`:

### `FlickrUITests/Helpers/FlickrUITestCase.swift` (NEW)
Base `XCTestCase` with:
- `var app: XCUIApplication!`
- `setUpWithError()` → `continueAfterFailure = false`; `app = XCUIApplication()`; adds default launch args `["-ui-testing"]`; calls `app.launch()`
- `launchApp(extraArgs: [String] = [])` helper
- Convenience accessors: `searchField`, `navBar`, `firstPhoto`, `photo(id:)`, `toolbarToggleButton`, `editorSaveButton`, `pageViewScroll`
- `waitForPhoto(id:timeout:)` helper that uses `XCTNSPredicateExpectation` to wait for async image load
- Import `@testable import Flickr` is **not** used — UI tests don't touch app internals. Identifier strings are duplicated in a small helper (or the shared `AccessibilityIdentifiers.swift` file is added to both targets as described above).

### `FlickrUITests/AppLaunchUITests.swift` (NEW, replaces current template)
- `testAppLaunchesToMainScreen` — verify nav title "Flickr" + search field present
- `testLaunchPerformance` — keep performance metric
- `testLaunchScreenshot` — attach cold-launch screenshot

### `FlickrUITests/SearchFlowUITests.swift` (NEW)
- `testSearchFieldIsVisibleOnLaunch`
- `testTypingInSearchFieldAcceptsText` — type text, assert search field value
- `testSubmittingSearchLoadsPhotoResults` — type, press return, wait for photo items to appear (using stub's deterministic ids)
- `testEmptyResultsStateShowsNoErrorView` — launch with `-ui-testing-empty-results`, search, verify list is empty and no error banner

### `FlickrUITests/PhotoListUITests.swift` (NEW)
- `testPhotosLoadAfterSearch`
- `testTappingPhotoOpensDetailPageView` — tap `photo.item.1`, assert `pageView.scroll` exists
- `testLongPressingPhotoOpensEditor` — press-and-hold (`press(forDuration: 1.0)`), assert `editor.save` exists
- `testDeletingPhotoRemovesItFromList` — tap `photo.item.delete.1`, assert `photo.item.1` no longer exists
- `testPullToRefreshReloadsList` — perform swipe-down gesture on list, verify list reappears without errors
- `testPaginationLoadsMorePhotos` — scroll to bottom, verify photos beyond page 1 appear (e.g., `photo.item.21`)
- `testToggleViewModeSwitchesBetweenListAndPageView` — tap toggle button, verify toolbar icon SF symbol changes + layout differs

### `FlickrUITests/PhotoDetailUITests.swift` (NEW)
- `testPageViewShowsFocusedPhoto` — open detail, assert `pageView.page.1` exists
- `testHorizontalSwipeChangesPage` — swipeLeft on pageView, assert `pageView.page.2` visible
- `testSwipeDownDismissesDetailBackToList` — swipeDown, assert main list nav title visible again

### `FlickrUITests/PhotoEditorUITests.swift` (NEW)
- `testEditorShowsImageSliderAndSave` — long-press → editor → all 3 identifiers exist
- `testHueSliderAdjustmentUpdatesAngleLabel` — adjust slider via `adjust(toNormalizedSliderPosition:)`, read `editor.angleValue` label, assert it changed
- `testSaveButtonDismissesEditor` — tap save, assert editor gone and main list visible

### `FlickrUITests/SearchHistoryUITests.swift` (NEW)
- `testEmptyHistoryStateShownWhenNoSearches` — focus search field, assert `search.history.empty` visible
- `testRecentSearchesAppearInHistory` — search "dog", dismiss, refocus, assert `search.history.item.dog` visible
- `testTappingHistoryItemReRunsSearch` — tap history item, verify search field populated and list reloads
- `testDeletingHistoryItemRemovesIt` — tap `search.history.delete.dog`, assert `search.history.item.dog` gone
- `testClearingAllHistoryShowsEmptyState` — tap `search.history.clear`, assert `search.history.empty` visible

### `FlickrUITests/FlickrUITests.swift` (DELETE or empty the template — content replaced by the classes above)

---

## Critical files to modify or create

**Create (all new):**
- `Flickr/App/UITestingSupport.swift` — launch arg hook + stub service (DEBUG only)
- `Flickr/Common/AccessibilityIdentifiers.swift` — shared identifier constants, added to **both targets**
- `FlickrUITests/Helpers/FlickrUITestCase.swift`
- `FlickrUITests/AppLaunchUITests.swift`
- `FlickrUITests/SearchFlowUITests.swift`
- `FlickrUITests/PhotoListUITests.swift`
- `FlickrUITests/PhotoDetailUITests.swift`
- `FlickrUITests/PhotoEditorUITests.swift`
- `FlickrUITests/SearchHistoryUITests.swift`

**Modify (add identifiers + launch hook):**
- `Flickr/App/FlickrApp.swift` (add one line in `init()` before service registration)
- `Flickr/Screens/PhotoLists/SearchView/SearchableMainListView.swift`
- `Flickr/Screens/PhotoLists/MainList/MainListView.swift`
- `Flickr/Screens/PhotoLists/MainList/ListView.swift`
- `Flickr/Screens/PhotoLists/MainList/Item/PhotoItemView.swift`
- `Flickr/Screens/PhotoLists/PageView/PageView.swift`
- `Flickr/Screens/EditorView/EditorView.swift`

**Delete/replace:**
- `FlickrUITests/FlickrUITests.swift` (template — replaced by `AppLaunchUITests.swift`)
- `FlickrUITests/FlickrUITestsLaunchTests.swift` (template — rolled into `AppLaunchUITests.swift`)

**Xcode project (`Flickr.xcodeproj/project.pbxproj`):**
- Register all new `.swift` files in the correct targets (`Flickr`, `FlickrUITests`, both for `AccessibilityIdentifiers.swift`)
- No new targets, no changed build settings

---

## Reusable items already in the codebase

- `FlickrService` protocol at `Flickr/Services/FlickrService/FlickrService.swift:10` — the stub conforms to this directly, no shim needed
- `PhotoDTO`, `PageDTO` at `Flickr/Services/FlickrService/Models/FlickrDTO.swift` — stub builds fixtures from these (incl. existing `PhotoDTO.test(id:)` helper at line 45)
- `ServiceContainer.register(...)` API (see `AppServicesRegistrator.swift:45`) — stub registration uses the same API
- `PhotoStorage`, `HistoryStorage`, `ImageCacheService` — stub clears these on startup for deterministic state
- Existing `FlickrServiceMock` in `FlickrTests/PhotoService/Mock/FlickrServiceMock.swift` is **not** reused (it lives in the test target and isn't accessible from the app process during UI tests)

---

## Verification

### Run the full UI test suite on iPhone 15 Pro
```bash
xcodebuild test \
  -project Flickr.xcodeproj \
  -scheme FlickrUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:FlickrUITests
```
Expected: all test classes pass, no flakiness across 3 consecutive runs.

### Smoke-verify production path is untouched
```bash
xcodebuild build \
  -project Flickr.xcodeproj \
  -scheme Flickr \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -configuration Release
```
Expected: Release build succeeds (confirms `#if DEBUG` wrapping of `UITestingSupport` is correct). Then launch the app normally in the simulator — it should load real Flickr photos exactly as today.

### Per-class sanity runs (optional, during development)
```bash
xcodebuild test -project Flickr.xcodeproj -scheme FlickrUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:FlickrUITests/SearchFlowUITests
```

### Manual verification in Xcode
- Open `FlickrUITests` scheme → run (⌘U) → 30+ tests executing across 6 classes
- Inspect the test report: screenshots attached for launch + any failing step
- Confirm simulator is iPhone 15 Pro in the scheme's Test action destinations

### Expected coverage
~30 tests across 6 files covering:
- Search entry, submission, empty state
- Photo list rendering, tap, long-press, delete, pagination, pull-to-refresh, view mode toggle
- Page view horizontal paging + swipe-down dismiss
- Editor hue slider adjustment + save
- Search history populate, re-run, delete single, clear all, empty state
- Cold-launch smoke + screenshot
