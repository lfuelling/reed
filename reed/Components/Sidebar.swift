//
//  Sidebar.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct Sidebar: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var allChannels: [Channel]
    
    @Binding var selectedChannel: Channel?
    @Binding var selectedArticle: Article?

    var body: some View {
        List(selection: $selectedChannel) {
            ForEach(allChannels, id: \.id) { channel in
                NavigationLink(
                    destination: ChannelView(
                        title: channel.title!,
                        articles: getArticlesByChannelId(id: channel.id!),
                        selectedArticle: $selectedArticle)
                ) {
                    Text(verbatim: channel.title!).font(.headline)
                }
            }
        }.listStyle(SidebarListStyle())
    }
    
    func getArticlesByChannelId(id: UUID) -> [Article] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.predicate = NSPredicate(format: "channelId = %@", id.uuidString)
        request.returnsObjectsAsFaults = false
        do {
            let result = try viewContext.fetch(request)
            return result as! [Article]
            
        } catch {
            print("Failed to find articles for channel with id '" + id.uuidString + "'")
        }
        return []
    }
}
