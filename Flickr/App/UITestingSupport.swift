// UITestingSupport.swift
// Flickr
//
// Registers a deterministic stub FlickrService when the app is launched
// under XCUITest with the "-ui-testing" launch argument.
// Compiled only in DEBUG builds — zero impact on Release.

#if DEBUG
import UIKit

enum UITestingSupport {
    static func applyIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("-ui-testing") else { return }

        let returnEmpty = ProcessInfo.processInfo.arguments.contains("-ui-testing-empty-results")

        // Overwrite the real FlickrService with a deterministic stub.
        // Must be called *after* AppServicesRegistrator.registerAllServices()
        // so that this registration takes precedence.
        ServiceContainer.register(FlickrService.self) {
            let stub = FlickrServiceUITestStub()
            stub.returnEmpty = returnEmpty
            return stub
        }

        // Clear search history persisted from previous runs so history
        // tests always start from a clean state.
        HistoryStorage().clearAll()
    }
}

// MARK: - FlickrServiceUITestStub

/// Returns 20 deterministic photos per page (3 pages, 60 total).
/// Photo IDs are "1"…"60", titles "Test Photo 1"…"Test Photo 60".
/// Each image is a tiny 4×4 solid-colour PNG so the image pipeline
/// produces a real UIImage without any network calls.
final class FlickrServiceUITestStub: FlickrService, @unchecked Sendable {
    var returnEmpty = false

    private static let totalPages = 3
    private static let perPage = 20

    func search(for query: String, page: Int, perPage: Int, maxUploadDate: Date) async throws -> PageDTO {
        guard !returnEmpty else {
            return PageDTO(page: 1, pages: 1, perpage: 20, total: 0, photo: [])
        }

        let total = Self.totalPages * Self.perPage

        guard page >= 1, page <= Self.totalPages else {
            return PageDTO(page: page, pages: Self.totalPages, perpage: Self.perPage, total: total, photo: [])
        }

        let start = (page - 1) * Self.perPage + 1
        let end = start + Self.perPage - 1

        let photos = (start...end).map { index in
            PhotoDTO(
                id: "\(index)",
                owner: "test-owner",
                secret: "test-secret",
                server: "test-server",
                title: "Test Photo \(index)"
            )
        }

        return PageDTO(page: page, pages: Self.totalPages, perpage: Self.perPage, total: total, photo: photos)
    }

    func loadImageData(for photo: PhotoDTO, size: PhotoSize) async throws -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        return renderer.pngData { ctx in
            UIColor.systemBlue.setFill()
            ctx.fill(CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
        }
    }
}
#endif
