//
//  Meme.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import Foundation

struct TopLevelDictionary: Decodable {
    var code: Int
    var data: [Meme]
    var message: String
    var next: String?
}

struct Meme: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id = "ID"
        case bottomText
        case imageURL = "image"
        case name
        case rank
        case tags
        case topText
    }
    var id: Int
    var bottomText: String?
    var imageURL: String
    var name: String
    var rank: Int
    var tags: String
    var topText: String?
}
