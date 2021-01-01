//
//  PersistenceProvider.swift
//  reed
//
//  Created by Lukas Fülling on 22.12.20.
//

import Foundation
import CoreData
import FeedKit

class PersistenceProvider {
    private let ctx: NSManagedObjectContext
    let articles: ArticlePersistenceProvider
    let channels: ChannelPersistenceProvider
    
    init(ctx: NSManagedObjectContext) {
        self.ctx = ctx
        self.articles = ArticlePersistenceProvider(ctx: self.ctx)
        self.channels = ChannelPersistenceProvider(ctx: self.ctx)
    }
    
    func persistFeed(feed: RSSFeed, feedUrl: URL) {
        let imageId = channels.generateImage(feed: feed)
        if let channelId = channels.generate(feedURL: feedUrl, imageId: imageId, feed: feed) {
            print("Successfully updated channel '" + channelId.uuidString + "'!")
            
            feed.items?.forEach({item in
                if let articleId = articles.generate(channelId: channelId, item: item) {
                    print("Successfully updated article '" + articleId.uuidString + "'!")
                } else {
                    print("Unable to generate article!")
                }
            })
            
        } else {
            print("Unable to generate channel: '" + feedUrl.absoluteString + "'!")
        }
        
    }
    
    func save(callback: () -> Void) {
        if ctx.hasChanges {
            print("Saving data...")
            do {
                try ctx.save()
                callback()
            } catch {
                print("Failed saving updated data!")
            }
        } else {
            print("no changes...")
            callback()
        }
    }
    
    func deleteChannel(channel: Channel) {
        articles.getByChannelId(channelId: channel.id!).forEach({ article in
            ctx.delete(article)
            print("Deleted article '" + article.id!.uuidString + "'")
        })
        
        ctx.delete(channel)
        print("Deleted channel '" + channel.id!.uuidString + "'")
        do {
            try ctx.save()
        } catch {
            print("Failed saving context after deleting channel '" + channel.id!.uuidString + "'!")
        }
    }
    
    func resetDatabase() {
        do {
            try ctx.persistentStoreCoordinator?.managedObjectModel.entities.forEach { (entity) in
                if let name = entity.name {
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try ctx.execute(request)
                }
            }

            try self.ctx.save()
        } catch {
            print("Error resetting the database: \(error.localizedDescription)")
        }
    }
}
