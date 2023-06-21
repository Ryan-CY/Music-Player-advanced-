//
//  SearchViewController+Extension.swift
//  Music Player(advanced)
//
//  Created by Ryan Lin on 2023/4/21.
//

import Foundation
import UIKit

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text != "" {
            fetchMusic(term: searchBar.text ?? "")
            collectionView.reloadData()
            view.endEditing(true)
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        musics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(SongCollectionViewCell.self)", for: indexPath) as? SongCollectionViewCell else {fatalError("dequeueReusableCell SongCollectionViewCell Failed")}
        let song = musics[indexPath.row]
        
        cell.singer.adjustsFontSizeToFitWidth = true
        cell.singer.textColor = .darkGray
        //cell.songName.adjustsFontSizeToFitWidth = true
        cell.songName.textColor = .darkText
        
        cell.cellBackground.backgroundColor = UIColor(red: 216/255, green: 210/255, blue: 200/255, alpha: 1)
        cell.cellBackground.layer.cornerRadius = 7
        cell.singer.text = song.artistName
        cell.songName.text = song.trackName
        cell.songCover.image = UIImage(systemName: "photo")
        
        URLSession.shared.dataTask(with: song.artworkUrl500) { data, response, error in
            if let data,
               let _ = response as? HTTPURLResponse {
                //print("image statusCode", response.statusCode)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    cell.songCover.image = image
                    cell.songCover.contentMode = .scaleAspectFill
                }
            }
        }.resume()
        
        return cell
    }
}
