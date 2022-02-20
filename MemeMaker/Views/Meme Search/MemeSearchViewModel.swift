//
//  MemeSearchViewModel.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import Foundation

// Delegate method definitions
protocol MemeSearchViewModelDelegate: AnyObject {
    func allMemesReceived()
    func memesFiltered()
    func errorEncountered(error: Error)
}

class MemeSearchViewModel {
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
        guard let initialURL = URL.baseURL else { return }
        dataProvider.fetchMemes(from: initialURL) { [weak self] result in
            switch result {
            case .success(let topLevelDictionary):
                self?.topLevelDictionary = topLevelDictionary
                self?.allMemes.append(contentsOf: topLevelDictionary.data)
                self?.getRemainingMemes()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // When called, getRemainingMemes() loops through the remainder of the database and when the resulting data is an empty array, we know we have reached the end.
    func getRemainingMemes() {
        guard let topLevelDictionary = topLevelDictionary else { return }
        
        var thereAreMemesLeft = !topLevelDictionary.data.isEmpty
        
        // I was proud of the readability of this line.
        if thereAreMemesLeft {
            guard let nextURLString = topLevelDictionary.next,
                  let nextURL = URL(string: nextURLString) else { return }
            
            dataProvider.fetchMemes(from: nextURL) { [weak self] result in
                switch result {
                    
                case .success(let nextTopLevelDictionary):
                    self?.topLevelDictionary = nextTopLevelDictionary
                    self?.allMemes.append(contentsOf: nextTopLevelDictionary.data)
                    thereAreMemesLeft = !nextTopLevelDictionary.data.isEmpty
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
