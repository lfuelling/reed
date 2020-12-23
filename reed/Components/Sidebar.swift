//
//  Sidebar.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct Sidebar: View {
    
    let persistenceProvider: PersistenceProvider
    let allChannels: [Channel]
    
    @Binding var selectedChannel: Channel?
    @Binding var selectedArticle: Article?

    var body: some View {
        List(selection: $selectedChannel) {
            ForEach(allChannels, id: \.id) { channel in
                if(channel.title != nil) {
                    NavigationLink(
                        destination: ChannelView(
                            articles: persistenceProvider.articles.getByChannelId(channelId: channel.id!),
                            channel: channel,
                            selectedArticle: $selectedArticle)
                    ) {
                        Text(verbatim: channel.title!).font(.headline)
                    }
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
