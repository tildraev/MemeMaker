//
//  MemeListViewController.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import UIKit

class MemeListViewController: UIViewController, APIDataProvidable {
    
    // MARK: - Properties
    var viewModel: MemeListViewModel!
    
    // MARK: - IBOutlets
    @IBOutlet weak var memeTableView: UITableView!
    
    // MARK: - Lifecycle method(s)
    override func viewDidLoad() {
        super.viewDidLoad()
        memeTableView.delegate = self
        memeTableView.dataSource = self
        viewModel = MemeListViewModel(delegate: self)
        viewModel.fetchMemes(from: URL.baseURL!)
    }
    
    // MARK: - Navigation
    // Navigation to the meme editor VC. As before, this just passes an image.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMemeEditorVC" {
            if let index = memeTableView.indexPathForSelectedRow {
                if let destination = segue.destination as? MemeEditorViewController {
                    let imageURLString = viewModel.memes[index.row].imageURL
                    guard let imageURL = URL(string: imageURLString) else { return }
                    perform(with: URLRequest(url: imageURL)) { data in
                        switch data {
                        case .success(let data):
                            let imageToSend = UIImage(data: data)
                            destination.viewModel = MemeEditorViewModel(delegate: destination)
                            destination.viewModel.memeImage = imageToSend
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}

// Required tableview delegate and datasource methods
extension MemeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memeCell", for: indexPath) as? MemeTableViewCell else { return UITableViewCell() }
        
        // Configure the cell...
        let meme = viewModel.memes[indexPath.row]
        cell.updateViews(with: meme)
        cell.selectionStyle = .none
        return cell
    }
    
    // Pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.memes.count-1 {
            guard let nextURL = URL(string: viewModel.topLevelDictionary?.next ?? "") else { return }
            viewModel.fetchMemes(from: nextURL)
        }
    }
}

// Delegate methods
extension MemeListViewController: MemeListViewModelDelegate {
    func memesRetrieved() {
        self.memeTableView.reloadData()
    }
    
    func errorEncountered(error: Error) {
        print(error.localizedDescription)
    }
}
