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
    
    func refreshChannels() -> Void {
        allChannels = persistenceProvider.channels.getAll()
    }
    
    func refetchAllFeeds() {
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
                            // Refresh UI
                            print("Done fetching '" + channel.updateUri! + "'!")
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
        refreshChannels()
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
                            ChannelView(title: channel.title!, articles: articles, selectedArticle: $selectedArticle)
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
                    ArticleView(article: article)
                } else {
                    Text("Select article...")
                }
            }.navigationTitle(selectedChannel?.title ?? "reed")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("􀅈") {
                        refreshChannels()
                        refetchAllFeeds()
                    }
                }
            }
            .onAppear(perform: refreshChannels)
        }
        #if os(macOS)
        Settings {
            SettingsView(persistenceProvider: persistenceProvider)
        }
        #endif
    }
}
