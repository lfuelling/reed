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
    
    @AppStorage("showBookmarksOnly") private var showBookmarksOnly = false
    
    let persistenceProvider: PersistenceProvider
    
    @State private var refreshing: Bool = false
    
    @State @ObservedObject var appState: AppState
    
    init () {
        self.persistenceProvider = PersistenceProvider(ctx: PersistenceController.shared.container.viewContext)
        self.appState = AppState(persistenceProvider: self.persistenceProvider)

        refreshChannels()
        refetchAllFeeds()
    }
    
    func refreshChannels() -> Void {
        if !refreshing {
            print("Reloading channels...")
            appState.allChannels = persistenceProvider.channels.getAll()
            
            if let channelId = appState.selectedChannel?.id {
                appState.selectedChannel = persistenceProvider.channels.getById(id: channelId)
            }
        }
    }
    
    func refetchAllFeeds() {
        if(!refreshing && appState.allChannels.count > 0) {
            print("Refreshing " + String(appState.allChannels.count) + " channels...")
            self.refreshing = true
            appState.allChannels.forEach({channel in
                if let feedUrl = channel.updateUri {
                    FeedUtils(persistenceProvider: persistenceProvider).fetchAndPersistFeed(feedUrl: feedUrl, callback: {
                        self.refreshing = false
                        self.refreshChannels()
                    })
                }
            })
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                
                Sidebar (
                    persistenceProvider: persistenceProvider,
                    refreshData: refreshChannels,
                    allChannels: appState.allChannels,
                    articlesForChannel: appState.articlesForChannel,
                    selectedChannel: appState.$selectedChannel,
                    selectedArticle: appState.$selectedArticle
                )
                
                if let channelId = appState.selectedChannel?.id {
                    if let channel = persistenceProvider.channels.getById(id: channelId) {
                        ChannelView(
                            articles: appState.articlesForChannel,
                            channel: channel,
                            persistenceProvider: persistenceProvider,
                            refreshData: refreshChannels,
                            selectedArticle: appState.$selectedArticle
                        )
                    } else {
                        Text("Channel not found...")
                    }
                } else {
                    Text("Select channel...")
                }
                
                if let articleId = appState.selectedArticle?.id {
                    if let article = persistenceProvider.articles.getById(id: articleId) {
                        ArticleView(
                            article: article,
                            channel: persistenceProvider.channels.getById(id: article.channelId!)!,
                            persistenceProvider: persistenceProvider,
                            refreshData: refreshChannels
                        )
                    }
                } else {
                    Text("Select article...")
                }
            }.navigationTitle(appState.selectedChannel?.title ?? "reed")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button {
                            showBookmarksOnly = !showBookmarksOnly
                            refreshChannels()
                        } label: {
                            if(showBookmarksOnly) {
                                Image(systemName: "star.fill")
                            } else {
                                Image(systemName: "star")
                            }
                        }
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
