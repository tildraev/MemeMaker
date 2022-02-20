//
//  APIDataProvidable.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import Foundation

//API protocol declaration
protocol APIDataProvidable {
    func perform(with urlRequest: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

//Reusable code that returns raw data to be used (ie "unwrapped/decoded") by a data provider
extension APIDataProvidable {
    func perform(with urlRequest: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                completion(.failure(.unexpectedError))
                print(error.localizedDescription)
                return
            }
            guard let data = data else {
                completion(.failure(.couldNotUnwrap))
                return
            }
            completion(.success(data))
        }.resume()
    }
}

//Extending the URL class to have a new static constant for our base URL
extension URL {
    static let baseURL = URL(string: "http://alpha-meme-maker.herokuapp.com")
}
