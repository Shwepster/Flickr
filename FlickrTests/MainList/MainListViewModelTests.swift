//
//  MainListViewModelTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 09.10.2024.
//

import XCTest
import Combine
@testable import Flickr

@MainActor
final class MainListViewModelTests: XCTestCase {
    private var viewModel: MainListView.ViewModel!
    private var paginationController: FlickrSearchPaginationControllerMock!
    private var stateListener: AnyCancellable?

    override func setUp() async throws {
        AppServicesRegistrator.registerAllServices()
        paginationController = FlickrSearchPaginationControllerMock()
        viewModel = .init(paginationController: paginationController)
    }
    
    override func tearDown() async throws {
        stateListener?.cancel()
        stateListener = nil
        paginationController.resetMock()
        paginationController = nil
        viewModel = nil
    }
    
    // MARK: - Tests
    
    func testLoadingStateTransition() async {
        let expectedStates: [MainListView.ViewModel.State] = [
            .idle,
            .loading,
            .idle,
            .loading,
            .idle,
            .loading,
            .allPagesLoaded
        ]
        
        var receivedStates: [MainListView.ViewModel.State] = []
        
        stateListener = viewModel.$state.sink { state in
            receivedStates.append(state)
        }
        
        await viewModel.onSearch("cat")
        await viewModel.onPaginate()
        paginationController.isNextPage = false
        await viewModel.onPaginate()

        XCTAssertEqual(receivedStates, expectedStates, "States should match expected sequence")
    }
    
    func testPagination() async {
        paginationController.photos = PhotoDTO.mocks
        await viewModel.onSearch("cat")
        await viewModel.onPaginate()
        XCTAssertEqual(
            viewModel.photoViewModels.map(\.photoId),
            (PhotoDTO.mocks + PhotoDTO.mocks).map(\.id),
            "Must have loaded photos two times"
        )
    }
    
    func testPaginationEnd() async {
        await testPagination()
        
        paginationController.isNextPage = false
        await viewModel.onPaginate()
        XCTAssertEqual(viewModel.state, .allPagesLoaded, "Must have reached end of pages")
    }
    
    func testRefresh() async {
        await testPagination()
        let newPhotos = [PhotoDTO.mock5]
        paginationController.page = 2
        paginationController.photos = newPhotos

        var receivedStates: [MainListView.ViewModel.State] = []
        stateListener = viewModel.$state.sink { state in
            receivedStates.append(state)
        }
        
        await viewModel.refresh()
        
        XCTAssertEqual(receivedStates, [.idle, .loading, .idle],
                       "Refresh should transition to loading and then back to idle")
        
        XCTAssertEqual(
            viewModel.photoViewModels.map(\.photoId),
            newPhotos.map(\.id),
            "New photos must replace old ones"
        )
        XCTAssertEqual(paginationController.page, 0, "Page must be reset")
    }
    
    func testSearchingNewTerm() async {
        await testSearchingTwoTermsSequentially(first: "cat", second: "dog")
    }
    
    func testSearchingSameTermTwice() async {
        let term = "cat"
        await testSearchingTwoTermsSequentially(first: term, second: term)
    }
    
    func testErrorState() async {
        let error = FlickrError.invalidApiKey
        paginationController.error = error
        let metadata = ErrorMetadata(error: error)
        
        let expectedStates: [MainListView.ViewModel.State] = [.idle, .loading, .error(metadata.message)]
        var receivedStates: [MainListView.ViewModel.State] = []
        stateListener = viewModel.$state.sink { state in
            receivedStates.append(state)
        }
        
        await viewModel.onSearch("cat")
        XCTAssertEqual(receivedStates, expectedStates, "State transitions must reflect error scenario")
        
        await viewModel.onSearch("cat")
        XCTAssertEqual(viewModel.state, .error(metadata.message), "Must be in error state with correct message")
    }
    
    func testSearchingAfterError() async {
        await testErrorState()
        
        paginationController.error = nil
        await viewModel.onSearch("cat")
        XCTAssertEqual(viewModel.state, .idle, "Search must be possible after error")
    }
    
    // MARK: - Helpers
    
    private func testSearchingTwoTermsSequentially(first: String, second: String) async {
        let firstPhotosBatch = PhotoDTO.mocks + PhotoDTO.mocks
        let secondPhotosBatch = [PhotoDTO.mock2]
        paginationController.photos = firstPhotosBatch
        
        await viewModel.onSearch(first)
        paginationController.page = 2
        XCTAssertEqual(viewModel.photoViewModels.count, firstPhotosBatch.count, "Must have loaded photos")
        
        paginationController.photos = [.mock2]
        await viewModel.onSearch(second)
        XCTAssertEqual(
            viewModel.photoViewModels.map(\.photoId),
            secondPhotosBatch.map(\.id),
            "Old photos must be replaced by new one photo"
        )
        XCTAssertEqual(paginationController.page, 0, "Page must be reset")
    }
}
