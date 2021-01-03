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
    
    @Binding var updater: Bool
    
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
    
    private func getUnreadIndicator(channel: Channel) -> some View {
        let unreadCount = getArticlesForChannel(id: channel.id!).filter({ a in
            return !a.read
        }).count
        
        if(unreadCount > 0) {
            return AnyView(Text(String(unreadCount))
                            .font(.subheadline)
                            .padding(4)
                            .background(Color.secondary.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 7)))
        }
        return AnyView(Text("").opacity(0))
    }
    
    var body: some View {
        List(allChannels, id: \.id, selection: $selectedChannel) { channel in
            if(channel.title != nil) {
                NavigationLink(
                    destination: ChannelView(
                        articles: getArticlesForChannel(id: channel.id!),
                        channel: channel,
                        updater: $updater,
                        persistenceProvider: persistenceProvider,
                        refreshData: refreshData,
                        selectedArticle: $selectedArticle
                    )
                ) {
                    HStack {
                        Text(verbatim: channel.title!)
                            .font(.headline)
                        Spacer()
                        getUnreadIndicator(channel: channel)
                    }
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
