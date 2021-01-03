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
    
    @AppStorage("autoUpdate") private var autoUpdate = true
    @AppStorage("updateInterval") private var updateInterval = 5.0
    
    let persistenceProvider = PersistenceProvider(ctx: PersistenceController.shared.container.viewContext)
    
    @State private var selectedChannel: Channel? = nil
    @State private var selectedArticle: Article? = nil
    
    @State private var allChannels: [Channel] = []

    @State private var showBookmarksOnly = false
    @State private var refreshing: Bool = false
    @State private var updater: Bool = false
    
    func refreshChannels() -> Void {
        if !refreshing {
            print("Reloading channels...")
            allChannels = persistenceProvider.channels.getAll()
        }
    }
    
    func refetchAllFeeds() {
        if(!refreshing && allChannels.count > 0) {
            print("Refreshing " + String(allChannels.count) + " channels...")
            self.refreshing = true
            allChannels.forEach({channel in
                if let feedUrl = channel.updateUri {
                    FeedUtils(persistenceProvider: persistenceProvider).fetchAndPersistFeed(feedUrl: feedUrl, callback: { error in
                        if let safeError = error {
                            print(safeError)
                        }
                        self.refreshing = false
                        self.refreshChannels()
                    })
                }
            })
        }
    }
    
    private func getArticleView(updater: Bool) -> some View {
        if let article = selectedArticle {
            return AnyView(ArticleView(
                article: article,
                channel: persistenceProvider.channels.getById(id: article.channelId!)!,
                persistenceProvider: persistenceProvider,
                refreshData: refreshChannels,
                updater: $updater
            ))
        } else {
            return AnyView(Text("Select article..."))
        }
    }
    
    private func getChannelView(updater: Bool) -> some View {
        if let channelId = selectedChannel?.id {
            if let channel = persistenceProvider.channels.getById(id: channelId) {
                return AnyView(ChannelView(
                    articles: getArticlesForChannel(id: channelId),
                    channel: channel,
                    updater: $updater,
                    persistenceProvider: persistenceProvider,
                    refreshData: refreshChannels,
                    selectedArticle: $selectedArticle
                ))
            } else {
                return AnyView(Text("Channel not found...").frame(minWidth: 300))
            }
        } else {
            return AnyView(Text("Select channel...").frame(minWidth: 300))
            
        }
    }
    
    private func getSidebarView(updater: Bool) -> some View {
        return List(allChannels, id: \.id, selection: $selectedChannel) { channel in
            if(channel.title != nil) {
                NavigationLink(
                    destination: ChannelView(
                        articles: getArticlesForChannel(id: channel.id!),
                        channel: channel,
                        updater: $updater,
                        persistenceProvider: persistenceProvider,
                        refreshData: refreshChannels,
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
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 150)
    }
    
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
        let unreadCount = persistenceProvider.articles.getByChannelId(channelId: channel.id!).filter({ a in
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
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                getSidebarView(updater: updater)
                getChannelView(updater: updater)
                getArticleView(updater: updater)
            }.navigationTitle(selectedChannel?.title ?? "reed")
            .toolbar {
                
                ToolbarItem(placement: .primaryAction) {
                    if let safeArticle = selectedArticle {
                        if let safeLink = safeArticle.link {
                            Button {
                                NSWorkspace.shared.open(safeLink)
                            } label: {
                                Image(systemName: "globe")
                            }.disabled(refreshing)
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
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
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        refreshChannels()
                        refetchAllFeeds()
                    } label: {
                        if refreshing {
                            Image(systemName: "hourglass")
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }.disabled(refreshing)
                }
            }
            .onAppear(perform: {
                refreshChannels()
                refetchAllFeeds()
                if autoUpdate {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (updateInterval * 60)) {
                        automaticUpdate()
                    }
                }
            })
        }
        #if os(macOS)
        Settings {
            SettingsView(persistenceProvider: persistenceProvider, refresh: refetchAllFeeds)
        }
        #endif
    }
    
    private func automaticUpdate() {
        print("Running automatic update...")
        refreshChannels()
        refetchAllFeeds()
        print("Scheduling next update...")
        if autoUpdate {
            DispatchQueue.main.asyncAfter(deadline: .now() + (updateInterval * 60)) {
                automaticUpdate()
            }
        }
    }
}
