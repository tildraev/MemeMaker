//
//  MemeTableViewCell.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import UIKit

class MemeTableViewCell: UITableViewCell {

    // MARK: - IBOutlets. Note AsyncImageView in place of UIImageView
    @IBOutlet weak var memeImageView: AsyncImageView!
    @IBOutlet weak var memeLabel: UILabel!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        memeImageView.image = nil
        memeLabel.text = nil
    }
    
    // Simple ipdate views functions that sets an image.
    func updateViews(with meme: Meme) {
        if let url = URL(string: meme.imageURL) {
            memeImageView.setImage(using: URLRequest(url: url))
        }
        memeLabel.text = meme.name
    }
}
