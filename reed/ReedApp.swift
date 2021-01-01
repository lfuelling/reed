//
//  reedApp.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import SwiftUI
import Cocoa
import CoreData
import FeedKit

@main
struct ReedApp: App {
    
    let persistenceProvider = PersistenceProvider(ctx: PersistenceController.shared.container.viewContext)
    
    @State private var selectedChannel: Channel? = nil
    @State private var selectedArticle: Article? = nil
    
    @State private var allChannels: [Channel] = []
    @State private var articlesForChannel: [Article] = []
    
    @State private var refreshing: Bool = false
    
    func refreshChannels() -> Void {
        if !refreshing {
            print("Reloading channels...")
            allChannels = persistenceProvider.channels.getAll()
            
            if let channelId = selectedChannel?.id {
                selectedChannel = persistenceProvider.channels.getById(id: channelId)
                articlesForChannel = persistenceProvider.articles.getByChannelId(channelId: channelId)
            }
        }
    }
    
    func refetchAllFeeds() {
        if(!refreshing && allChannels.count > 0) {
            print("Refreshing " + String(allChannels.count) + " channels...")
            self.refreshing = true
            allChannels.forEach({channel in
                if let feedUrl = channel.updateUri {
                    FeedUtils(persistenceProvider: persistenceProvider).fetchAndPersistFeed(feedUrl: feedUrl, callback: {
                        self.refreshing = false
                        self.refreshChannels()
                    })
                }
            })
        }
    }
    
    init () {
        refreshChannels()
        refetchAllFeeds()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Sidebar (
                    persistenceProvider: persistenceProvider,
                    allChannels: allChannels,
                    refreshData: refreshChannels,
                    selectedChannel: $selectedChannel,
                    selectedArticle: $selectedArticle
                )
                
                if let channelId = selectedChannel?.id {
                    if let channel = persistenceProvider.channels.getById(id: channelId) {
                            ChannelView(
                                channel: channel,
                                persistenceProvider: persistenceProvider,
                                refreshData: refreshChannels,
                                selectedArticle: $selectedArticle,
                                articles: articlesForChannel
                            )
                    } else {
                        Text("Channel not found...")
                    }
                } else {
                    Text("Select channel...")
                }
                
                if let article = selectedArticle {
                    ArticleView(
                        article: article,
                        channel: persistenceProvider.channels.getById(id: article.channelId!)!,
                        persistenceProvider: persistenceProvider,
                        refreshData: refreshChannels
                    )
                } else {
                    Text("Select article...")
                }
            }.navigationTitle(selectedChannel?.title ?? "reed")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        refreshChannels()
                        refetchAllFeeds()
                    } label: {
                        if(refreshing) {
                            Image(systemName: "hourglass")
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }.disabled(refreshing)
                }
            }
            .onAppear(perform: refreshChannels)
        }
        #if os(macOS)
        Settings {
            SettingsView(persistenceProvider: persistenceProvider, refresh: refetchAllFeeds)
        }
        #endif
    }
}
