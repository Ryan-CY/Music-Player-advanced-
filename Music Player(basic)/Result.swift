//
//  Result.swift
//  Music Player(advanced)
//
//  Created by Ryan Lin on 2023/4/20.
//

import Foundation

struct Result: Decodable {
    let results: [Song]
}

struct Song: Decodable, Equatable {
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: String
    
    //change image size
    var artworkUrl500: URL {
        URL(string: artworkUrl100)!.deletingLastPathComponent().appendingPathComponent("500x500.jpg")
    }
}
