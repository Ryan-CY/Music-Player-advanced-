//
//  MusicPlayerViewController+Extension.swift
//  Music Player(advanced)
//
//  Created by Ryan Lin on 2023/4/27.
//

import Foundation
import AVFoundation
import UIKit

extension MusicPlayerViewController {
    
    static let player = AVPlayer()
    static var songPicture: UIImage?
    static var songName = ""
    static var singer = ""
    static var controllerVolume = Float(0.5)
    static var timerCurrent: Timer?
}
