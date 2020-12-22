//
//  ChannelPersistenceProvider.swift
//  reed
//
//  Created by Lukas Fülling on 22.12.20.
//

import Foundation
import SwiftUI
import FeedKit

class ChannelPersistenceProvider {
    private let ctx: NSManagedObjectContext
    
    init(ctx: NSManagedObjectContext) {
        self.ctx = ctx
    }
    
    func generateImage(feed: RSSFeed) -> UUID? {
        // TODO: detect duplicates and only update instead
        if(feed.image != nil) {
            let channelImageEntity = NSEntityDescription.entity(forEntityName: "ChannelImage", in: ctx)
            let ci = NSManagedObject(entity: channelImageEntity!, insertInto: ctx)
            let id = UUID()
            ci.setValue(id, forKey: "id")
            ci.setValue(feed.image?.url, forKey: "url")
            ci.setValue(feed.image?.title, forKey: "title")
            ci.setValue(feed.image?.link, forKey: "link")
            return id
        }
        return nil
    }
    
    func getExistingOrNew(feedUrl: URL, feed: RSSFeed) -> NSManagedObject {
        var c: NSManagedObject? = nil
        var id: UUID? = nil
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.predicate = NSPredicate(format: "updateUri = %@", feedUrl.absoluteString)
        request.returnsObjectsAsFaults = false
        do {
            let result = try ctx.fetch(request) as! [NSManagedObject]
            if result.count >= 1 {
                c = result[0]
                id = c?.value(forKey: "id") as? UUID
                print("Found existing channel: '" + id!.uuidString + "'")
            }
        } catch {
            // TODO: better error handling
            print("Failed to find any existing channel with url '" + feedUrl.absoluteString + "'!")
        }
        
        
        // TODO: detect duplicates and only update instead
        if(c == nil) {
            print("Creating new channel...")
            let channelEntity = NSEntityDescription.entity(forEntityName: "Channel", in: ctx)
            c = NSManagedObject(entity: channelEntity!, insertInto: ctx)
        }
        if(id == nil) {
            id = UUID()
            c!.setValue(id, forKey: "id")
        }
        return c!
    }
    
    func generate(feedURL: URL, imageId: UUID?, feed: RSSFeed) -> UUID {
        
        let c = getExistingOrNew(feedUrl: feedURL, feed: feed)
        
        c.setValue(feed.title, forKey: "title")
        c.setValue(feed.description, forKey: "channelDescription")
        c.setValue(feed.link, forKey: "link")
        c.setValue(imageId, forKey: "channelImageId")
        c.setValue(feed.generator, forKey: "generator")
        c.setValue(feed.lastBuildDate, forKey: "lastBuildDate")
        c.setValue(feed.ttl, forKey: "ttl")
        c.setValue(feedURL.absoluteString, forKey: "updateUri")
        
        let id = c.value(forKey: "id") as! UUID
        return id
    }
    
    func getById(id: UUID) -> Channel? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.predicate = NSPredicate(format: "id = %@", id.uuidString)
        request.returnsObjectsAsFaults = false
        do {
            let result = try ctx.fetch(request)
            if(result.count > 0) {
                return result[0] as? Channel
            } else {
                print("Unable to find channel by id '" + id.uuidString + "'")
                return nil
            }
        } catch {
            print("Failed to find channel by id '" + id.uuidString + "'")
        }
        return nil
    }
    
    func getAll() -> [Channel] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.returnsObjectsAsFaults = false
        do {
            let result = try ctx.fetch(request)
            return result as! [Channel]
        } catch {
            // TODO: better error handling
            print("Failed to find channels!")
        }
        return []
    }
}
