//
//  Sidebar.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct Sidebar: View {
    
    var persistenceProvider: PersistenceProvider
    
    @Binding var selectedChannel: Channel?
    @Binding var selectedArticle: Article?
    
    @State var allChannels: [Channel] = []

    var body: some View {
        List(selection: $selectedChannel) {
            ForEach(allChannels, id: \.id) { channel in
                if(channel.title != nil) {
                    NavigationLink(
                        destination: ChannelView(
                            title: channel.title!,
                            articles: persistenceProvider.articles.getByChannelId(channelId: channel.id!),
                            selectedArticle: $selectedArticle)
                    ) {
                        Text(verbatim: channel.title!).font(.headline)
                    }
                }
            }
        }.listStyle(SidebarListStyle())
        .onAppear(perform: getChannels)
    }
    
    func getChannels() {
        allChannels = persistenceProvider.channels.getAll()
    }
}
