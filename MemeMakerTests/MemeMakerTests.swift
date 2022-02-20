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
    var searchViewModel: MockMemeSearchViewModel!
    let dataProvider = MockDataProvider()
    let delegate = MockDelegate()
    
    override func setUp() {
        super.setUp()
        viewModel = MockMemeListViewModel(dataProvider: dataProvider, delegate: delegate)
        searchViewModel = MockMemeSearchViewModel(dataProvider: dataProvider, delegate: delegate)
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    func testMemeListViewModelEmptyState() {
        ///Given: App launches to meme list tab
        ///When: nothing has been done
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
    
    func testMemeSearchListViewModelInitialState() {
        ///Given user navigates to search tab and no search or data retrieval has been completed yet
        ///When nothing has been done
        ///Then topLevelDictionary should be nil
        XCTAssertNil(searchViewModel.topLevelDictionary)
    }
    
    func testMemeSearchListViewModelDataRetrieved() {
        ///Given user navigates and the project retrieves data from a valid API
        searchViewModel.fetchAllMemes()
        ///When a user has not searched yet
        ///Then topLevelDictionary should already have the full array of memes
        XCTAssertTrue(searchViewModel.topLevelDictionary?.data.count == 3)
    }
    
    func testSearchResultsFiltered() {
        ///Given all results have been prepopulated
        searchViewModel.fetchAllMemes()
        XCTAssertTrue(searchViewModel.topLevelDictionary?.data.count == 3)
        ///When a user searched for a tag/name "isIncluded"
        searchViewModel.filterMemes(searchTerm: "isIncluded")
        ///Then filteredmemes should have two items
        XCTAssertTrue(searchViewModel.filteredMemes.count == 2)
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

class MockMemeSearchViewModel {
    // MARK: - Properties
    weak var delegate: MemeSearchViewModelDelegate?
    var dataProvider: DataProvidable
    var topLevelDictionary: TopLevelDictionary?
    var allMemes: [Meme] = []
    var filteredMemes: [Meme] = []
    
    // MARK: - Initializer
    init(dataProvider: DataProvidable = DataProvider(), delegate: MemeSearchViewModelDelegate) {
        self.dataProvider = dataProvider
        self.delegate = delegate
    }
    
    // MARK: - Helper functions
    // fetchAllMemes() first pulls the memes from page (1) of our API, and then called getRemainingMemes() to loop through the remainder of the database.
    func fetchAllMemes() {
        dataProvider.fetchMemes(from: URL(string: "test")!) { [weak self] result in
            switch result {
            case .success(let topLevelDictionary):
                self?.topLevelDictionary = topLevelDictionary
                self?.allMemes.append(contentsOf: topLevelDictionary.data)
                //self?.getRemainingMemes()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // When called, getRemainingMemes() loops through the remainder of the database and when the resulting data is an empty array, we know we have reached the end.
    func getRemainingMemes() {
        //guard let topLevelDictionary = topLevelDictionary else { return }
        
        var thereAreMemesLeft = true
        
        // I was proud of the readability of this line.
        if thereAreMemesLeft {
            //guard let nextURLString = topLevelDictionary.next,
                  //let nextURL = URL(string: nextURLString) else { return }
            
            dataProvider.fetchMemes(from: URL(string: "test")!) { [weak self] result in
                switch result {
                    
                case .success(let nextTopLevelDictionary):
                    self?.topLevelDictionary = nextTopLevelDictionary
                    self?.allMemes.append(contentsOf: nextTopLevelDictionary.data)
                    thereAreMemesLeft = false
                    self?.getRemainingMemes()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            delegate?.allMemesReceived()
        }
    }
    
    //Filters memes by tag and name.
    func filterMemes(searchTerm: String) {
        filteredMemes = []
        for meme in allMemes {
            if (meme.tags.lowercased().contains(searchTerm.lowercased()) || meme.name.lowercased().contains(searchTerm.lowercased())) {
                filteredMemes.append(meme)
            }
        }
        delegate?.memesFiltered()
    }
}

struct MockDataProvider: DataProvidable, APIDataProvidable {
    func fetchMemes(from url: URL, completion: @escaping (Result<TopLevelDictionary, NetworkError>) -> Void) {
        switch url.absoluteString {
        case "successTest":
            completion(.success(TopLevelDictionary(code: 1, data: [Meme(id: 1, bottomText: "test", imageURL: "test", name: "test", rank: 1, tags: "test", topText: "test")], message: "test", next: "test")))
        case "failTest":
            completion(.failure(.couldNotUnwrap))
        case "test":
            completion(.success(TopLevelDictionary(code: 1, data: [Meme(id: 1, bottomText: "test", imageURL: "test", name: "isIncluded", rank: 1, tags: "isIncluded", topText: "test"),
                                                                   Meme(id: 2, bottomText: "test", imageURL: "test", name: "isNotIncluded", rank: 2, tags: "isNotIncluded", topText: "test"),
                                                                   Meme(id: 3, bottomText: "test", imageURL: "test", name: "isIncluded", rank: 3, tags: "isIncluded", topText: "test")], message: "test", next: "test")))
        default:
            print("default case")
        }
    }
}

class MockDelegate: MemeListViewModelDelegate, MemeSearchViewModelDelegate {
    func allMemesReceived() {
        
    }
    
    func memesFiltered() {
        
    }
    
    func memesRetrieved() {
    }
    
    func errorEncountered(error: Error) {
        
    }
}
