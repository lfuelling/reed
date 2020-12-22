//
//  ArticlePersistenceProvider.swift
//  reed
//
//  Created by Lukas Fülling on 22.12.20.
//

import Foundation
import FeedKit
import CoreData

class ArticlePersistenceProvider {
    private let ctx: NSManagedObjectContext
    
    init(ctx: NSManagedObjectContext) {
        self.ctx = ctx
    }
    
    private func getCategoryString(categories: [RSSFeedItemCategory]?) -> String {
        var res = "["
        categories?.forEach({cat in
            res += cat.value! + ","
        })
        res.remove(at: res.index(before: res.endIndex)) // remove trailing comma
        res += "]"
        return res
    }
    
    func getExistingOrNew(channelId: UUID, item: RSSFeedItem) -> NSManagedObject {
        var a: NSManagedObject? = nil
        var id: UUID? = nil
        if let itemGuid = item.guid?.value {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
            request.predicate = NSPredicate(format: "guid = %@ AND channelId = %@", itemGuid, channelId.uuidString)
            request.returnsObjectsAsFaults = false
            do {
                let result = try ctx.fetch(request) as! [NSManagedObject]
                if result.count >= 1 {
                    a = result[0]
                    id = a?.value(forKey: "id") as? UUID
                    print("Found existing article: '" + id!.uuidString + "'")
                }
            } catch {
                // TODO: better error handling
                print("Failed to find any existing article with guid '" + itemGuid + "'!")
            }
        }
        
        // TODO: detect duplicates and only update instead
        if(a == nil) {
            print("Creating new article...")
            let articleEntity = NSEntityDescription.entity(forEntityName: "Article", in: ctx)
            a = NSManagedObject(entity: articleEntity!, insertInto: ctx)
        }
        if(id == nil) {
            id = UUID()
            a!.setValue(id, forKey: "id")
        }
        return a!
    }
    
    func getContentString(item: RSSFeedItem) -> String {
        if let content = item.content {
            if let encodedContent = content.contentEncoded {
                return encodedContent
            }
        }
        
        if let description = item.description {
            return description
        }
        
        if let title = item.title {
            return title
        }
        
        return "No content..."
    }
    
    func generate(channelId: UUID, item: RSSFeedItem) -> UUID? {
        if(item.title == nil) {
            print("Error: Item has no title!")
        } else {
            let a = getExistingOrNew(channelId: channelId, item: item)
            
            a.setValue(item.pubDate, forKey: "date")
            a.setValue(item.title ?? "No title", forKey: "title")
            a.setValue(item.description ?? item.title, forKey: "articleDescription")
            a.setValue(item.link, forKey: "link")
            a.setValue(item.guid?.value, forKey: "guid")
            a.setValue(getCategoryString(categories: item.categories), forKey: "categories")
            a.setValue(item.author, forKey: "author")
            a.setValue(getContentString(item: item), forKey: "content")
            a.setValue(channelId, forKey: "channelId")
            
            let id = a.value(forKey: "id") as! UUID
            return id
        }
        return nil
    }
    
    func getByChannelId(channelId: UUID) -> [Article] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.predicate = NSPredicate(format: "channelId = %@", channelId.uuidString)
        request.returnsObjectsAsFaults = false
        do {
            let result = try ctx.fetch(request)
            return result as! [Article]
            
        } catch {
            print("Failed to find articles for channel with id '" + channelId.uuidString + "'")
        }
        return []
    }
}
