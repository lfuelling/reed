//
//  reedApp.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import SwiftUI
import Cocoa
import CoreData

@main
struct ReedApp: App {
    
    let persistenceController = PersistenceController.shared

    @State private var selectedChannel: UUID? = nil
    @State private var selectedArticle: Article?
    
    init() {
        generateDummyData(persistenceController.container.viewContext)
    }
    
    func getChannelById(id: UUID) -> Channel? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.predicate = NSPredicate(format: "id = %@", id.uuidString)
        request.returnsObjectsAsFaults = false
        do {
            let result = try persistenceController.container.viewContext.fetch(request)
            return result[0] as? Channel
        } catch {
            print("Failed to find channel by id '" + id.uuidString + "'")
        }
        return nil
    }
    
    func getArticlesByChannelId(id: UUID) -> [Article] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.predicate = NSPredicate(format: "channelId = %@", id.uuidString)
        request.returnsObjectsAsFaults = false
        do {
            let result = try persistenceController.container.viewContext.fetch(request)
            return result as! [Article]
            
        } catch {
            print("Failed to find articles for channel with id '" + id.uuidString + "'")
        }
        return []
    }
    
    func getAllChannels() -> [Channel] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.returnsObjectsAsFaults = false
        do {
            let result = try persistenceController.container.viewContext.fetch(request)
            return result as! [Channel]
            
        } catch {
            print("Failed to find channels!")
        }
        return []
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Sidebar (
                    allChannels: getAllChannels(),
                    selectedChannel: $selectedChannel,
                    selectedArticle: $selectedArticle
                )
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                if let channelId = selectedChannel {
                    if let channel = getChannelById(id: channelId) {
                        if let articles = getArticlesByChannelId(id: channel.id!) {
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
            }
        }
        #if os(macOS)
        Settings {
            SettingsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        #endif
    }
}
