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
    let articlesForChannel: [Article]

    @Binding var selectedChannel: Channel?
    @Binding var selectedArticle: Article?

    var body: some View {
        List(selection: $selectedChannel) {
            ForEach(allChannels, id: \.id) { channel in
                NavigationLink(
                    destination: ChannelView(
                        articles: articlesForChannel,
                        channel: channel,
                        persistenceProvider: persistenceProvider,
                        refreshData: refreshData,
                        selectedArticle: $selectedArticle
                    )
                ) {
                    Text(verbatim: channel.title!).font(.headline)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
