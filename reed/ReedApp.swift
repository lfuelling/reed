//
//  reedApp.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import SwiftUI
import Cocoa

@main
struct ReedApp: App {
    
    @StateObject var channelStore = DummyChannelStore()
    @StateObject var articleStore = DummyArticleStore()
    
    @State private var selectedChannel: UUID? = dummyChannelOne.id
    @State private var selectedArticle: Article?
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Sidebar (
                    channelStore: channelStore,
                    articleStore: articleStore,
                    selectedChannel: $selectedChannel,
                    selectedArticle: $selectedArticle
                )
                
                if let channelId = selectedChannel {
                    if let channel = channelStore.getChannelById(id: channelId) {
                        if let articles = articleStore.allArticles[channel.id] {
                            ChannelView(title: channel.title, articles: articles, selectedArticle: $selectedArticle)
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
            }
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
