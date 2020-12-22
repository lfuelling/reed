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
        self.articles = ArticlePersistenceProvider(ctx: ctx)
        self.channels = ChannelPersistenceProvider(ctx: ctx)
    }
    
    func persistFeed(feed: RSSFeed, feedUrl: URL) {
        let imageId: UUID? = channels.generateImage(feed: feed)
        let channelId: UUID = channels.generate(feedURL: feedUrl, imageId: imageId, feed: feed)
        print("Successfully updated channel '" + channelId.uuidString + "'!")
        
        feed.items?.forEach({item in
            let articleId: UUID = articles.generate(channelId: channelId, item: item)
            print("Successfully updated article '" + articleId.uuidString + "'!")
        })
    }
    
    func save(callback: () -> Void) {
        print("Saving data...")
        do {
            try ctx.save()
            callback()
        } catch {
            print("Failed saving updated data!")
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
}
