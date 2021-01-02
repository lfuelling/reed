//
//  AppState.swift
//  reed
//
//  Created by Lukas Fülling on 02.01.21.
//

import Foundation

class AppState: ObservableObject {
    private let persistenceProvider: PersistenceProvider

    @Published var allChannels: [Channel] = []
    @Published var selectedArticle: Article? = nil
    @Published var articlesForChannel: [Article] = []
    @Published var selectedChannel: Channel? = nil {
        didSet {
            if let channelId = selectedChannel?.id {
                articlesForChannel = persistenceProvider.articles.getByChannelId(channelId: channelId)
            }
        }
    }
    
    init (persistenceProvider: PersistenceProvider) {
        self.persistenceProvider = persistenceProvider
    }
}
