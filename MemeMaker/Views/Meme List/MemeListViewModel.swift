//
//  MemeListViewModel.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import Foundation

// Delegate protocol definition
protocol MemeListViewModelDelegate: AnyObject {
    func memesRetrieved()
    func errorEncountered(error: Error)
}

class MemeListViewModel {
    // MARK: - Properties
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
        dataProvider.fetchMemes(from: url) { [weak self] result in
            switch result {
            case .success(let topLevelDictionary):
                DispatchQueue.main.async {
                    self?.memes.append(contentsOf: topLevelDictionary.data)
                    self?.topLevelDictionary = topLevelDictionary
                    self?.delegate?.memesRetrieved()                    
                }
            case .failure(let error):
                self?.delegate?.errorEncountered(error: error)
            }
        }
    }
}

// Data providable protocol declaration
protocol DataProvidable {
    func fetchMemes(from url: URL, completion: @escaping (Result<TopLevelDictionary, NetworkError>) -> Void)
}

// Building a data provider that we can use across the app to decode data.
struct DataProvider: APIDataProvidable, DataProvidable {
    func fetchMemes(from url: URL, completion: @escaping (Result<TopLevelDictionary, NetworkError>) -> Void) {
        perform(with: URLRequest(url: url)) { data in
            switch data {
            case .success(let encodedData):
                do {
                    let decodedTopLevelDictionary = try JSONDecoder().decode(TopLevelDictionary.self, from: encodedData)
                    completion(.success(decodedTopLevelDictionary))
                } catch {
                    completion(.failure(.errorDecoding(error)))
                }
            case .failure(let error):
                completion(.failure(.badURL(url)))
                print(error.localizedDescription)
            }
        }
    }
}
