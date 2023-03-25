//
//  YoutubeSearchResponse.swift
//  NetflixClone
//
//  Created by jayden on 2023/03/25.
//

import Foundation


struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IDVideoElement
}

struct IDVideoElement: Codable {
    let kind: String
    let videoId: String
}
