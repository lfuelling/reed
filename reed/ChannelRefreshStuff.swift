//
//  ChannelRefreshStuff.swift
//  reed
//
//  Created by Lukas Fülling on 22.12.20.
//

import Foundation
import SwiftUI
import FeedKit

func generateChannelImage(ctx: NSManagedObjectContext, feed: RSSFeed) -> UUID? {
    // TODO: detect duplicates and only update instead
    if(feed.image != nil) {
        let channelImageEntity = NSEntityDescription.entity(forEntityName: "ChannelImage", in: ctx)
        let ci = NSManagedObject(entity: channelImageEntity!, insertInto: ctx)
        let id = UUID()
        ci.setValue(id, forKey: "id")
        ci.setValue(feed.image?.url, forKey: "url")
        ci.setValue(feed.image?.title, forKey: "title")
        ci.setValue(feed.image?.link, forKey: "link")
        do {
            try ctx.save()
        } catch {
            print("Failed saving ChannelImage with id '" + id.uuidString + "'!")
        }
        return id
    }
    return nil
}

func generateChannel(ctx: NSManagedObjectContext, feedURL: URL, imageId: UUID?, feed: RSSFeed) -> UUID {
    // TODO: detect duplicates and only update instead
    let channelEntity = NSEntityDescription.entity(forEntityName: "Channel", in: ctx)
    let c = NSManagedObject(entity: channelEntity!, insertInto: ctx)
    let id = UUID()
    
    c.setValue(id, forKey: "id")
    c.setValue(feed.title, forKey: "title")
    c.setValue(feed.description, forKey: "channelDescription")
    c.setValue(feed.link, forKey: "link")
    c.setValue(imageId, forKey: "channelImageId")
    c.setValue(feed.generator, forKey: "generator")
    c.setValue(feed.lastBuildDate, forKey: "lastBuildDate")
    c.setValue(feed.ttl, forKey: "ttl")
    c.setValue(feedURL.absoluteString, forKey: "updateUri")
    do {
        try ctx.save()
    } catch {
        print("Failed saving Channel with id '" + id.uuidString + "'!")
    }
    return id
}

func getCategoryString (categories: [RSSFeedItemCategory]) -> String {
    var res = "["
    categories.forEach({cat in
        res += cat.value! + ","
    })
    res.remove(at: res.index(before: res.endIndex)) // remove trailing comma
    res += "]"
    return res
}

func generateArticle(ctx: NSManagedObjectContext, channelId: UUID, item: RSSFeedItem) -> UUID {
    // TODO: detect duplicates and only update instead
    let articleEntity = NSEntityDescription.entity(forEntityName: "Article", in: ctx)
    let a = NSManagedObject(entity: articleEntity!, insertInto: ctx)
    let id = UUID()
    
    a.setValue(id, forKey: "id")
    a.setValue(item.pubDate, forKey: "date")
    a.setValue(item.title, forKey: "title")
    a.setValue(item.description, forKey: "articleDescription")
    a.setValue(item.link, forKey: "link")
    a.setValue(item.guid?.value, forKey: "guid")
    a.setValue(getCategoryString(categories: item.categories!), forKey: "categories")
    a.setValue(item.author, forKey: "author")
    a.setValue(item.content?.contentEncoded, forKey: "content")
    a.setValue(channelId, forKey: "channelId")
    do {
        try ctx.save()
    } catch {
        print("Failed saving Article with id '" + id.uuidString + "'!")
    }
    return id
}

func persistFeed(ctx: NSManagedObjectContext, feed: RSSFeed, feedUrl: URL) {
    let imageId: UUID? = generateChannelImage(ctx: ctx, feed: feed)
    let channelId: UUID = generateChannel(ctx: ctx, feedURL: feedUrl, imageId: imageId, feed: feed)
    print("Successfully created channel '" + channelId.uuidString + "'!")
    
    feed.items?.forEach({item in
        let articleId: UUID = generateArticle(ctx: ctx, channelId: channelId, item: item)
        print("Successfully created article '" + articleId.uuidString + "'!")
    })
}
