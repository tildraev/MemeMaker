//
//  MemeSearchViewController.swift
//  MemeMaker
//
//  Created by Arian Mohajer on 2/17/22.
//

import UIKit

class MemeSearchViewController: UIViewController, APIDataProvidable {

    // MARK: - Properties
    var viewModel: MemeSearchViewModel!
    
    // MARK: - Outlets
    @IBOutlet weak var filteredMemesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Lifecycle method(s)
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredMemesTableView.dataSource = self
        filteredMemesTableView.delegate = self
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        viewModel = MemeSearchViewModel(delegate: self)
        viewModel.fetchAllMemes()
    }
    
    // MARK: - Navigation
    // Preparing for our segue to the editing VC. Checking IIDOO. Passing a specific image here for the editor to work with.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMemeEditorVC" {
            if let index = filteredMemesTableView.indexPathForSelectedRow {
                if let destination = segue.destination as? MemeEditorViewController {
                    let imageURLString = viewModel.filteredMemes[index.row].imageURL
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

// MARK: - Delegate functions for our search view controller. 
extension MemeSearchViewController: MemeSearchViewModelDelegate {
    func allMemesReceived() {
        DispatchQueue.main.async {
            self.filteredMemesTableView.reloadData()
        }
    }
    
    func memesFiltered() {
        DispatchQueue.main.async {
            self.filteredMemesTableView.reloadData()
        }
    }
    
    func errorEncountered(error: Error) {
        print(error.localizedDescription)
    }
}

// Delegate functions specific to our table view.
extension MemeSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredMemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memeCell", for: indexPath) as? MemeTableViewCell else { return UITableViewCell() }
        
        let meme = viewModel.filteredMemes[indexPath.row]
        // Passing on a meme for each cell to be updated with
        cell.updateViews(with: meme)
        cell.selectionStyle = .none
        return cell
    }
}

// Search bar delegate methods. Filters memes by text input.
extension MemeSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterMemes(searchTerm: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
