//
//  MemeEditorViewModel.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import Foundation
import UIKit

// MemeEditorViewModelDelegate declaration
protocol MemeEditorViewModelDelegate: AnyObject {
    func imageWasReceived(memeImage: UIImage)
}

class MemeEditorViewModel {
    
    weak var delegate: MemeEditorViewModelDelegate?
    
    init(delegate: MemeEditorViewModelDelegate) {
        self.delegate = delegate
    }
    
    // As soon as the image is set, call our delegate method
    var memeImage: UIImage? {
        didSet {
            guard let memeImage = memeImage else { return }
            delegate?.imageWasReceived(memeImage: memeImage)
        }
    }
}
