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
    @State private var refreshing: Bool = false
    
    func refreshChannels() -> Void {
        allChannels = persistenceProvider.channels.getAll()
    }
    
    func refetchAllFeeds() {
        refreshing = true
        allChannels.forEach({channel in
            if(channel.updateUri != nil) {
                if let feedUrl = URL(string: channel.updateUri!) {
                    let parser = FeedParser(URL: feedUrl)
                    
                    // Parse asynchronously, not to block the UI.
                    parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) {(result) in
                        
                        switch result {
                        case .success(let feed):
                            switch feed {
                            case .rss(let feed):
                                persistenceProvider.persistFeed(feed: feed, feedUrl: feedUrl)
                                break
                            default:
                                print("Currently only RSS is supported!")
                                break
                            }
                            
                            DispatchQueue.main.async {
                                persistenceProvider.save(callback: {() -> Void in
                                    // Refresh UI
                                    refreshChannels()
                                    refreshing = false
                                })
                            }
                            
                        case .failure(let error):
                            print("Error parsing feed!")
                            print(error)
                        }
                    }
                    
                } else {
                    // TODO: show error
                }
            }
        })
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Sidebar (
                    persistenceProvider: persistenceProvider,
                    selectedChannel: $selectedChannel,
                    selectedArticle: $selectedArticle
                )
                
                if let channelId = selectedChannel?.id {
                    if let channel = persistenceProvider.channels.getById(id: channelId) {
                        if let articles = persistenceProvider.articles.getByChannelId(channelId: channel.id!) {
                            ChannelView(articles: articles, channel: channel, persistenceProvider: persistenceProvider, selectedArticle: $selectedArticle)
                        }
                        else {
                            Text("No articles...")
                        }
                    } else {
                        Text("Channel not found...")
                    }
                } else {
                    Text("Select channel...")
                }
                
                if let article = selectedArticle {
                    ArticleView(article: article, persistenceProvider: persistenceProvider)
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
