//
//  Sidebar.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct Sidebar: View {
    @ObservedObject var channelStore: DummyChannelStore
    @ObservedObject var articleStore: DummyArticleStore
    @Binding var selectedChannel: UUID?
    @Binding var selectedArticle: Article?

    var body: some View {
        List(selection: $selectedChannel) {
            ForEach(channelStore.allChannels, id: \.self) { channel in
                NavigationLink(
                    destination: ChannelView(
                        title: channel.title,
                        articles: articleStore.allArticles[channel.id, default: []],
                        selectedArticle: $selectedArticle)
                ) {
                    Text(verbatim: channel.title).font(.headline)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
