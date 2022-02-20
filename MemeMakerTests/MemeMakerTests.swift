//
//  MemeMakerTests.swift
//  MemeMakerTests
//
//  Created by Arian Mohajer on 2/19/22.
//

import XCTest
@testable import MemeMaker

class MemeListViewModelTests: XCTestCase {
    
    var viewModel: MockMemeListViewModel!
    let dataProvider = MockDataProvider()
    let delegate = MockDelegate()
    
    override func setUp() {
        super.setUp()
        viewModel = MockMemeListViewModel(dataProvider: dataProvider, delegate: delegate)
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    func testMemeListViewModelEmptyState() {
        ///Given: App launches to meme list tab
        ///When: viewModel fetches and asynchronous code is run
        ///Then: TopLevelDictionary should be empty if we have not fetched "memes"
        XCTAssertNil(viewModel.topLevelDictionary)
    }
    
    func testMemeListViewModelDataProviderSuccess() {
        ///Given app launch, and view model told to fetch from valid URL
        viewModel.fetchMemes(from: URL(string: "successTest")!)
        ///When search is completed
        ///Then topLevelDictionary should have values
        XCTAssertNotNil(viewModel.topLevelDictionary)
        ///Then data should have exactly one value
        XCTAssertTrue(viewModel.topLevelDictionary?.data.count == 1)
    }
    
    func testMemeListViewModelDataProviderFailure() {
        ///Given app launch, and view model told to fetch from INvalid URL
        viewModel.fetchMemes(from: URL(string: "failureTest")!)
        ///When search is completed
        ///Then topLevelDictionary should have values
        XCTAssertNil(viewModel.topLevelDictionary)
    }
}

class MockMemeListViewModel {
    var topLevelDictionary: TopLevelDictionary?
    var dataProvider: DataProvidable
    var memes: [Meme] = []
    weak var delegate: MemeListViewModelDelegate?
    
    init(dataProvider: DataProvidable = DataProvider(), delegate: MemeListViewModelDelegate) {
        self.dataProvider = dataProvider
        self.delegate = delegate
    }
    
    // MARK: - Helper functions
    //fetchMemes() grabs the first list of memes and is called when paginat..ing...
    func fetchMemes(from url: URL) {
        dataProvider.fetchMemes(from: url) { result in
            switch result {
            case .success(let tld):
                self.topLevelDictionary = tld
            case .failure(_):
                print("failure")
            }
        }
    }
}

struct MockDataProvider: DataProvidable, APIDataProvidable {
    func fetchMemes(from url: URL, completion: @escaping (Result<TopLevelDictionary, NetworkError>) -> Void) {
        switch url.absoluteString {
        case "successTest":
            completion(.success(TopLevelDictionary(code: 1, data: [Meme(id: 1, bottomText: "test", imageURL: "test", name: "test", rank: 1, tags: "test", topText: "test")], message: "test", next: "test")))
        case "failTest":
            completion(.failure(.couldNotUnwrap))
        default:
            print("default case")
        }
    }
}

class MockDelegate: MemeListViewModelDelegate {
    func memesRetrieved() {
    }
    
    func errorEncountered(error: Error) {
        
    }
}
