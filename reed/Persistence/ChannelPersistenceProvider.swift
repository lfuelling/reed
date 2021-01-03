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
            let id = UUID()
            self.ctx.perform {
                let channelImageEntity = NSEntityDescription.entity(forEntityName: "ChannelImage", in: self.ctx)
                let ci = NSManagedObject(entity: channelImageEntity!, insertInto: self.ctx)
                ci.setValue(id, forKey: "id")
                ci.setValue(feed.image?.url, forKey: "url")
                ci.setValue(feed.image?.title, forKey: "title")
                ci.setValue(feed.image?.link, forKey: "link")
            }
            return id
        }
        return nil
    }
    
    func generateImage(feed: AtomFeed) -> UUID? {
        // TODO: detect duplicates and only update instead
        if(feed.icon != nil) {
            let id = UUID()
            self.ctx.perform {
                let channelImageEntity = NSEntityDescription.entity(forEntityName: "ChannelImage", in: self.ctx)
                let ci = NSManagedObject(entity: channelImageEntity!, insertInto: self.ctx)
                ci.setValue(id, forKey: "id")
                if let safeIcon = feed.icon {
                    ci.setValue(safeIcon, forKey: "url")
                } else if let safeLogo = feed.logo {
                    ci.setValue(safeLogo, forKey: "url")
                }
            }
            return id
        }
        return nil
    }
    
    func getExistingOrNew(feedUrl: URL) -> NSManagedObject {
        var c: NSManagedObject? = nil
        var id: UUID? = nil
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.predicate = NSPredicate(format: "updateUri = %@", feedUrl.absoluteString)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.ctx.fetch(request) as! [NSManagedObject]
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
            let channelEntity = NSEntityDescription.entity(forEntityName: "Channel", in: self.ctx)
            c = NSManagedObject(entity: channelEntity!, insertInto: self.ctx)
        }
        if(id == nil) {
            id = UUID()
            c!.setValue(id, forKey: "id")
        }
        
        return c!
    }
    
    private func getLinkUri(channel: RSSFeed) -> URL? {
        if let safeLink = channel.link {
            return URL(string: safeLink)
        }
        return nil
    }
    
    private func getLinkUri(channel: AtomFeed) -> URL? {
        if let safeLink = channel.links?[0].attributes?.href {
            // TODO: Maybe not just use the first link but that's enough for now I guess...
            return URL(string: safeLink)
        }
        return nil
    }
    
    func generate(feedURL: URL, imageId: UUID?, feed: RSSFeed) -> UUID? {
        let c = getExistingOrNew(feedUrl: feedURL)
        
        c.setValue(feed.title ?? feedURL.absoluteString, forKey: "title")
        c.setValue(feed.description, forKey: "channelDescription")
        c.setValue(getLinkUri(channel: feed), forKey: "link")
        c.setValue(imageId, forKey: "channelImageId")
        c.setValue(feed.generator, forKey: "generator")
        c.setValue(feed.lastBuildDate, forKey: "lastBuildDate")
        c.setValue(feed.ttl, forKey: "ttl")
        c.setValue(feedURL, forKey: "updateUri")
        
        let id = c.value(forKey: "id") as! UUID
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                print("Error saving!")
            }
        }
        return id
    }
    
    func generate(feedURL: URL, imageId: UUID?, feed: AtomFeed) -> UUID? {
        let c = getExistingOrNew(feedUrl: feedURL)
        
        c.setValue(feed.title ?? feedURL.absoluteString, forKey: "title")
        c.setValue(feed.subtitle?.value, forKey: "channelDescription")
        c.setValue(getLinkUri(channel: feed), forKey: "link")
        c.setValue(imageId, forKey: "channelImageId")
        c.setValue(feed.generator?.value, forKey: "generator")
        c.setValue(feedURL, forKey: "updateUri")
        
        let id = c.value(forKey: "id") as! UUID
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                print("Error saving!")
            }
        }
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
