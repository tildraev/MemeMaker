//
//  AsyncImageView.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import UIKit

//Subclass of UIImageView allowing an UIImageView to essentially unwrap it's own image.
class AsyncImageView: UIImageView, APIDataProvidable {
    func setImage(using urlRequest: URLRequest) {
        perform(with: urlRequest) { [weak self] result in
            DispatchQueue.main.async {
                guard let imageData = try? result.get() else { return }
                self?.image = UIImage(data: imageData)
            }
        }
    }
}
