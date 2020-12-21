//
//  Article.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct Article: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let title: String
    let description: String
    let link: String
    let guid: String
    let categories: [String]
    let author: String
    let content: String
    let mediaUris: [String]
    let channelId: UUID
}
