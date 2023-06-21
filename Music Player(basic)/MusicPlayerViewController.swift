//
//  MusicPlayerViewController.swift
//  Music Player(basic)
//
//  Created by Ryan Lin on 2023/4/21.
//

import UIKit
//載入AVFoundation函式庫(framework)
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var songPhotoImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var playingTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var timeSlider: UISlider!
    
    let player = AVPlayer()
    var timeObserverToken: Any?
    var currentTime = Double(0)
    var musics = [Song]()
    var index = 0
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        volume()
        playMusic()
        configuration()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
            
            if self.repeatButton.imageView?.image == UIImage(systemName: "repeat") {
                //自動播放下一首
                //print("🔁🔁🔁")
                self.player.pause()
                self.index = (self.index + 1) % self.musics.count
                self.currentTime = 0
                self.playMusic()
            } else if self.repeatButton.imageView?.image == UIImage(systemName: "repeat.1") {
                //print("🔂")
                self.player.pause()
                
                self.currentTime = 0
                self.playMusic()
            }
        }
    }
    
    //playing music in background
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        return true
    }
    
    func volume() {
        volumeSlider.value = 0.5
        player.volume = volumeSlider.value
    }
    
    func playMusic() {
        
        // 4 steps to play music
        url = musics[index].previewUrl
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        //show pause button
        playPauseButton.configuration?.image = UIImage(systemName: "pause.fill")
        //show album cover
        URLSession.shared.dataTask(with: musics[self.index].artworkUrl500) { data, response, error in
            if let data,
               let response = response as? HTTPURLResponse {
                print("image statusCode", response.statusCode)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.songPhotoImageView.image = image
                    self.songPhotoImageView.contentMode = .scaleAspectFill
                }
            }
        }.resume()
        
        //show song name
        songLabel.text = musics[self.index].trackName
        //show singer
        singerLabel.text = musics[self.index].artistName
        
        //show totoal time
        let totaltime = (player.currentItem?.asset.duration.seconds)!
        let newTotalTime = Int(totaltime).quotientAndRemainder(dividingBy: 60)
        let showTotalTime = "\(newTotalTime.quotient):\(newTotalTime.remainder)"
        self.totalTimeLabel.text = showTotalTime
        self.timeSlider.maximumValue = Float(totaltime)
        //show process of time
        if self.currentTime.isZero == true {
            addPerioedTimeObserver()
        }
    }
    
    func timeConfiguration() {
        // insure app against crashing by currentTime being Nan or infinite
        guard !(currentTime.isNaN || currentTime.isInfinite) else {return}
        
        let intCurrentTime = Int(self.currentTime)
        let newCurrentTime = intCurrentTime.quotientAndRemainder(dividingBy: 60)
        let showCurrentTime = "\(newCurrentTime.quotient):\(newCurrentTime.remainder)"
        print("index \(index)", showCurrentTime)
        
        self.playingTimeLabel.text = showCurrentTime
        
        self.timeSlider.minimumValue = 0
        
        self.timeSlider.value = Float(self.currentTime)
        
    }
    
    func addPerioedTimeObserver() {
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)
        
        self.timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { _ in
            
            self.currentTime = self.player.currentTime().seconds
            print(self.currentTime)
            self.timeConfiguration()
            
        })
    }
    
//    func removePeriodTimeObserver() {
//
//        if let timeObserver = self.timeObserverToken {
//            player.removeTimeObserver(timeObserver)
//            self.timeObserverToken = nil
//        }
//    }
    
    
    func configuration() {
        
        songLabel.adjustsFontSizeToFitWidth = true
        singerLabel.adjustsFontSizeToFitWidth = true
        
        repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        
        let volumeImage = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        
        volumeSlider.setThumbImage(volumeImage, for: .normal)
        
        timeSlider.thumbTintColor = .systemTeal
        let sliderImage = UIImage(systemName: "app.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        timeSlider.setThumbImage(sliderImage, for: .normal)
        
        songPhotoImageView.layer.cornerRadius = CGFloat(20)
        shadowView.layer.cornerRadius = CGFloat(20)
        shadowView.layer.shadowOpacity = Float(1)
        shadowView.layer.shadowRadius = CGFloat(20)
        shadowView.layer.shadowColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    @IBAction func shuffleButton(_ sender: UIButton) {
        
        if shuffleButton.imageView?.image == UIImage(systemName: "shuffle.circle") {
            sender.setImage(UIImage(systemName: "arrow.right.circle"), for: .normal)
            self.index = 0
            self.currentTime = 0
            playMusic()
        } else if shuffleButton.imageView?.image == UIImage(systemName: "arrow.right.circle") {
            sender.setImage(UIImage(systemName: "shuffle.circle"), for: .normal)
            //songs array in rendom order
            musics.shuffle()
            self.currentTime = 0
            playMusic()
        }
    }
    
    @IBAction func playButtonChosen(_ sender: UIButton) {
        switch player.timeControlStatus {
            //playing song
        case .playing :
            //pause song
            player.pause()
            //change the image of button
            sender.configuration?.image = UIImage(systemName: "play.fill")
            
        default:
            player.play()
            sender.configuration?.image = UIImage(systemName: "pause.fill")
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        self.currentTime = 0
        player.pause()
        self.index = (self.index + 1) % musics.count
        playMusic()
    }
    
    @IBAction func preButton(_ sender: Any) {
        self.currentTime = 0
        player.pause()
        self.index = (self.index+musics.count-1) % musics.count
        playMusic()
    }
    
    @IBAction func changeVolumeSlider(_ sender: UISlider) {
        
        player.volume = sender.value
        //print("🔊MusicPlayerViewController.controllerVolume", MusicPlayerViewController.controllerVolume)
    }
    
    //change process of song while sliding the slider
    @IBAction func changeTimeSlider(_ sender: UISlider) {
        let time = CMTime(value: CMTimeValue(sender.value), timescale: 1)
        player.seek(to: time)
    }
    
    @IBAction func pressGoforward(_ sender: Any) {
        let time = CMTime(value: Int64(timeSlider.value + 5), timescale: 1)
        player.seek(to: time)
    }
    
    @IBAction func pressBackward(_ sender: Any) {
        let time = CMTime(value: Int64(timeSlider.value - 5), timescale: 1)
        player.seek(to: time)
    }
    
    @IBAction func pressRepeat(_ sender: Any) {
        if repeatButton.imageView?.image == UIImage(systemName: "repeat") {
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        } else {
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        }
    }
}
