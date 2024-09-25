//
//  PhotoServiceTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 24.09.2024.
//

import XCTest
@testable import Flickr

final class PhotoServiceTests: XCTestCase {
    private var service: PhotoService!
    private var flickrService: FlickrServiceMock!
    private let image = SharedTestData.image

    override func setUp() async throws {
        flickrService = FlickrServiceMock()
        let loader = PhotoLoaderRaw(flickrService: flickrService)
        service = PhotoService(photoLoader: loader)
    }

    override func tearDown() async throws {
        service.cancelAllPhotoLoading()
        flickrService.reset()
        flickrService = nil
        service = nil
    }
    
    // MARK: - Tests
    
    func testMultipleUniqueLoadings() async {
        flickrService.data = image.pngData()
        flickrService.delay = 0.3
        let photos = PhotoDTO.mocks
        await loadPhotosExpectedNonNil(photos: photos, expectedActiveTasks: photos.count)
    }
    
    func testRepeatingLoadings() async {
        flickrService.data = image.pngData()
        flickrService.delay = 0.3
        let photos = Array(repeating: PhotoDTO.mock, count: 5)
        // For the same 5 photos must be only 1 task
        await loadPhotosExpectedNonNil(photos: photos, expectedActiveTasks: 1)
    }
    
    func testLoadingLargeNumberOfPhotos() async {
        flickrService.data = image.pngData()
        flickrService.delay = 0.3
        let photos = Array(repeating: PhotoDTO.mock, count: 500)
        
        let startTime = Date()
        await loadPhotosExpectedNonNil(photos: photos, expectedActiveTasks: 1)
        let endTime = Date()
        XCTAssert(
            endTime.timeIntervalSince(startTime) < 30,
            "Photo loading should complete within 30 seconds"
        )
    }
    
    func testCancelAllLoadings() async {
        flickrService.data = image.pngData()
        flickrService.delay = 0.3
        let photos = PhotoDTO.mocks
        
        do {
            try await withThrowingTaskGroup(of: UIImage?.self) { [service] group in
                for photo in photos {
                    group.addTask {
                        await service!.loadImage(for: photo, size: .b)
                    }
                }
                
                try await waitForActiveTasks(toReach: photos.count)
                
                XCTAssertEqual(
                    service!.activeTasks,
                    photos.count,
                    "For each unique photo there should be one active task"
                )
                
                service!.cancelAllPhotoLoading()
                
                // All tasks must return nil
                var emptyImagesCount = 0
                for try await result in group {
                    XCTAssertNil(result)
                    if result == nil {
                        emptyImagesCount += 1
                    }
                }
                
                XCTAssertEqual(emptyImagesCount, photos.count)
                XCTAssertEqual(service!.activeTasks, 0, "All completed tasks should be removed")
            }
        } catch {
            XCTFail("Unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
    func testCancelSingleLoadingInMultiple() async {
        flickrService.data = image.pngData()
        flickrService.delay = 0.3
        let photos = PhotoDTO.mocks
        let photoToCancel = photos.randomElement()
        
        do {
            try await withThrowingTaskGroup(of: UIImage?.self) { [service] group in
                for photo in photos {
                    group.addTask {
                        await service!.loadImage(for: photo, size: .b)
                    }
                }
                
                try await waitForActiveTasks(toReach: photos.count)
                
                XCTAssertEqual(
                    service!.activeTasks,
                    photos.count,
                    "For each unique photo there should be one active task"
                )
                
                if let photoToCancel {
                    service!.cancelPhotoLoading(for: photoToCancel)
                } else {
                    XCTFail("No photo to cancel")
                }
                
                
                var emptyImagesCount = 0
                var completedImagesCount = 0
                
                for try await result in group {
                    if result == nil {
                        emptyImagesCount += 1
                    } else {
                        completedImagesCount += 1
                    }
                }
                
                XCTAssertEqual(emptyImagesCount, 1, "Only one empty image should be returned")
                XCTAssertEqual(completedImagesCount, photos.count - 1, "All non-cancelled photos should be returned")
                XCTAssertEqual(service!.activeTasks, 0, "All completed tasks should be removed")
            }
        } catch {
            XCTFail("Unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
    func testLoadingError() async {
        flickrService.data = image.pngData()
        flickrService.error = .other
        let photos = PhotoDTO.mocks
        await loadPhotosWithExpectedNil(photos, expectedNilCount: photos.count)
    }
    
    func testLoadingCorruptedImage() async {
        flickrService.data = Data()
        let photos = PhotoDTO.mocks
        await loadPhotosWithExpectedNil(photos, expectedNilCount: photos.count)
    }
    
    func testLoadingNoData() async {
        flickrService.data = nil
        let photos = PhotoDTO.mocks
        await loadPhotosWithExpectedNil(photos, expectedNilCount: photos.count)
    }
    
    func testFailingSecondRequest() async {
        flickrService.data = image.pngData()
        flickrService.failAfterRequestCount = 1
        flickrService.delay = 0.5
        let photos = PhotoDTO.mocks
        await loadPhotosWithExpectedNil(photos, expectedNilCount: photos.count-1)
    }
    
    func testFailingSecondRequestMultipleTimes() async throws {
        for i in 1...50 {
            print("Testing iteration \(i)")
            try await setUp()
            await testFailingSecondRequest()
        }
    }
    
    // MARK: - Helpers
    
    private func loadPhotosExpectedNonNil(photos: [PhotoDTO], expectedActiveTasks: Int) async {
        XCTAssert(flickrService.delay > 0, "Delay should be, to give tasks time to start")
        
        do {
            try await withThrowingTaskGroup(of: UIImage.self) { [service, flickrService] group in
                for photo in photos {
                    group.addTask {
                        let image = await service!.loadImage(for: photo, size: .b)
                        
                        if let image {
                            return image
                        } else {
                            XCTFail("Image should not be nil for unique photo loading")
                            throw XCTSkip("Image should not be nil")
                        }
                    }
                }
                
                // wait to give all tasks time to start
                try await waitForActiveTasks(toReach: expectedActiveTasks)
                
                XCTAssertEqual(
                    service!.activeTasks,
                    expectedActiveTasks,
                    "For each unique photo there should be only one active task"
                )
                                
                var totalImages = 0
                for try await result in group {
                    XCTAssertEqual(result.pngData(), flickrService!.data)
                    totalImages += 1
                }
                
                XCTAssertEqual(totalImages, photos.count)
                XCTAssertEqual(service!.activeTasks, 0, "All completed tasks should be removed")
            }
        } catch {
            XCTFail("Unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
    private func loadPhotosWithExpectedNil(_ photos: [PhotoDTO], expectedNilCount: Int) async {
        do {
            try await withThrowingTaskGroup(of: UIImage?.self) { [service] group in
                for photo in photos {
                    group.addTask {
                        await service!.loadImage(for: photo, size: .b)
                    }
                }
                
                var nilImagesCount = 0
                var totalImagesCount = 0
                for try await result in group {
                    totalImagesCount += 1
                    if result == nil {
                        nilImagesCount += 1
                    }
                }
                
                XCTAssertEqual(totalImagesCount, photos.count, "Expected \(photos.count) images")
                XCTAssertEqual(nilImagesCount, expectedNilCount, "Expected \(expectedNilCount) nil images")
                XCTAssertEqual(service!.activeTasks, 0, "All completed tasks should be removed")
            }
        } catch {
            XCTFail("Unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
    private func waitForActiveTasks(toReach expectedCount: Int, timeout: TimeInterval = 1.0) async throws {
        let startTime = Date()
        while service!.activeTasks != expectedCount {
            if Date().timeIntervalSince(startTime) > timeout {
                XCTFail("Timed out waiting for active tasks to reach \(expectedCount)")
                return
            }
            try await Task.sleep(for: .milliseconds(5))
        }
    }
}
