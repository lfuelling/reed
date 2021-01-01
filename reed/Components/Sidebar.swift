//
//  Sidebar.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct Sidebar: View {
    
    @AppStorage("showBookmarksOnly") private var showBookmarksOnly = false
    
    let persistenceProvider: PersistenceProvider
    let refreshData: () -> Void
    
    let allChannels: [Channel]
    
    @Binding var selectedChannel: Channel?
    @Binding var selectedArticle: Article?
    
    private func getArticlesForChannel(id: UUID) -> [Article] {
        var articlesForChannel: [Article] = []
        if showBookmarksOnly {
            articlesForChannel = persistenceProvider.articles.getByChannelId(channelId: id)
                .filter({ (a) -> Bool in return a.bookmarked })
        } else {
            articlesForChannel = persistenceProvider.articles.getByChannelId(channelId: id)
        }
        return articlesForChannel
    }

    var body: some View {
        List(selection: $selectedChannel) {
            ForEach(allChannels, id: \.id) { channel in
                if(channel.title != nil) {
                    
                    NavigationLink(
                        destination: ChannelView(
                            articles: getArticlesForChannel(id: channel.id!),
                            channel: channel,
                            persistenceProvider: persistenceProvider,
                            refreshData: refreshData,
                            selectedArticle: $selectedArticle
                        )
                    ) {
                        Text(verbatim: channel.title!).font(.headline)
                    }
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
