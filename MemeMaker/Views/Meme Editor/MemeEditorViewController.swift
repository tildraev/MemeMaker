//
//  MemeDetailViewController.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import UIKit

class MemeEditorViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    var viewModel: MemeEditorViewModel!
    
    // MARK: - IBOutlets
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var enterTopTextField: UITextField!
    @IBOutlet weak var enterBottomTextField: UITextField!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var bottomTextLabel: UILabel!
    
    // MARK: - IBActions
    //Simply sets label text equal to the value of the text fields
    @IBAction func setTextButtonTapped(_ sender: Any) {
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            .strokeColor : UIColor.black,
            .foregroundColor : UIColor.white,
            .strokeWidth : -3.0,
        ]
        
        topTextLabel.attributedText = NSAttributedString(string: enterTopTextField.text ?? "", attributes: strokeTextAttributes)
        bottomTextLabel.attributedText = NSAttributedString(string: enterBottomTextField.text ?? "", attributes: strokeTextAttributes)
        topTextLabel.text = enterTopTextField.text
        bottomTextLabel.text = enterBottomTextField.text
        
        enterTopTextField.resignFirstResponder()
        enterBottomTextField.resignFirstResponder()
    }
    
}

// Adopting the memeEditorViewModelDelegate protocol.
extension MemeEditorViewController: MemeEditorViewModelDelegate {
    func imageWasReceived(memeImage: UIImage) {
        DispatchQueue.main.async {
            guard let image = self.viewModel.memeImage else { return }
            self.memeImageView.image = self.viewModel.memeImage
            
            // Some "fancy" logic to help dictate whether we should be aspect fit or fill. This doesn't work as well as I'd like it to.
            if (image.size.height / image.size.width) > (self.memeImageView.frame.height / self.memeImageView.frame.width) {
                self.memeImageView.contentMode = .scaleAspectFit
            } else {
                self.memeImageView.contentMode = .scaleAspectFill
            }
        }
    }
}
