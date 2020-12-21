//
//  Channel.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ChannelImage: Hashable {
    let url: String
    let title: String
    let link: String
}

struct Channel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let image: ChannelImage
    let generator: String
    let lastBuildDate: String
    let ttl: Int
    let updateUri: String
}
