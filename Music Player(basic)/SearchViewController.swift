//
//  SearchViewController.swift
//  Music Player(advanced)
//
//  Created by Ryan Lin on 2023/4/21.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var musics = [Song]()
    
    func fetchMusic(term: String) {
        
        guard let urlString = "https://itunes.apple.com/search?term=\(term)&media=music&country=TW".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data,
               let response = response as? HTTPURLResponse {
                print("statusCode", response.statusCode)
                let decorder = JSONDecoder()
                do {
                    let result = try decorder.decode(Result.self, from: data)
                    self.musics = result.results
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search a Singer or Band"
        searchBar.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? MusicPlayerViewController,
              let index = collectionView.indexPathsForSelectedItems?.first?.item else { return }
        
        destination.index = index
        destination.musics = musics
    }
}
