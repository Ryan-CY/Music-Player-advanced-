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
    
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songStatusButton: UIButton!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var musics = [Song]()
    var controllerVolume = Float(0)
    var timerNames: Timer?
    var timerStatus: Timer?
    
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
        
        backgroundImageView.isHidden = true
        songImageView.isHidden = true
        songStatusButton.isHidden = true
        namesLabel.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timerNames?.invalidate()
        timerStatus?.invalidate()
        print("🛑timerNames stopped")
        print("🛑timerSongName stopped")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if namesLabel.isHidden == false {
            
            namesLabel.text = "\(MusicPlayerViewController.singer) / \(MusicPlayerViewController.songName)"
            
            timerNames = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                
                if MusicPlayerViewController.player.timeControlStatus == .playing {
                    self.showNamesTransition()
                    print("🌟Transition timer running")
                }
                
                if MusicPlayerViewController.timerCurrent?.isValid == true {
                    MusicPlayerViewController.timerCurrent?.invalidate()
                    print("list🛑timerCurrent?.invalidate()")
                }
                self.songStatus()
            }
        }
    }
    
    func showNamesTransition() {
        let transition = CATransition()
        transition.duration = 2.5
        transition.type = .push
        transition.subtype = .fromTop
        
        namesLabel.text = "\(MusicPlayerViewController.singer) / \(MusicPlayerViewController.songName)"
        
        namesLabel.layer.add(transition, forKey: "showNamesTransition")
    }
    
    func songStatus() {
        self.songImageView.image = MusicPlayerViewController.songPicture
        
        if MusicPlayerViewController.player.timeControlStatus == .playing {
            //print("playing")
            self.songStatusButton.configuration?.image = UIImage(systemName: "pause.circle")
            
        } else  {
            //print("pause")
            self.songStatusButton.configuration?.image = UIImage(systemName: "play.circle")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MusicPlayerViewController,
           let index = collectionView.indexPathsForSelectedItems?.first {
            
            MusicPlayerViewController.player.pause()
            destination.index = index.item
            destination.musics = musics
            MusicPlayerViewController.player.play()
            
            controllerVolume = MusicPlayerViewController.controllerVolume
            
            backgroundImageView.isHidden = false
            songImageView.isHidden = false
            songStatusButton.isHidden = false
            namesLabel.isHidden = false
            
            backgroundImageView.backgroundColor = UIColor(red: 46/255, green: 52/255, blue: 61/255, alpha: 1)
        }
    }
    
    @IBAction func choseSongStatusButton(_ sender: UIButton) {
        
        if MusicPlayerViewController.player.timeControlStatus == .playing {
            MusicPlayerViewController.player.pause()
            sender.configuration?.image = UIImage(systemName: "play.circle")
        } else {
            MusicPlayerViewController.player.play()
            sender.configuration?.image = UIImage(systemName: "pause.circle")
        }
    }
}
