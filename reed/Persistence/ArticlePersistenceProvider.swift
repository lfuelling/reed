//
//  ArticlePersistenceProvider.swift
//  reed
//
//  Created by Lukas Fülling on 22.12.20.
//

import Foundation
import FeedKit
import CoreData
import SwiftUI

class ArticlePersistenceProvider {
    @AppStorage("sortDescending") private var sortDescending = true
    
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
    
    private func getExistingOrNew(channelId: UUID, item: RSSFeedItem) -> NSManagedObject {
        var a: NSManagedObject? = nil
        var id: UUID? = nil
        
        if let itemLink = item.link {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
            request.predicate = NSPredicate(format: "link = %@ AND channelId = %@", itemLink, channelId.uuidString)
            request.returnsObjectsAsFaults = false
            do {
                let result = try self.ctx.fetch(request) as! [NSManagedObject]
                if result.count >= 1 {
                    a = result[0]
                    id = a?.value(forKey: "id") as? UUID
                    print("Found existing article: '" + id!.uuidString + "'")
                }
            } catch {
                // TODO: better error handling
                print("Failed to find any existing article with link '" + itemLink + "'!")
            }
        }
        
        // TODO: detect duplicates and only update instead
        if(a == nil) {
            print("Creating new article...")
            let articleEntity = NSEntityDescription.entity(forEntityName: "Article", in: self.ctx)
            a = NSManagedObject(entity: articleEntity!, insertInto: self.ctx)
        }
        if(id == nil) {
            id = UUID()
            a!.setValue(id, forKey: "id")
        }
        
        
        return a!
    }
    
    private func getContentString(item: RSSFeedItem) -> String {
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
    
    private func getMediaUri(item: RSSFeedItem) -> URL? {
        if let safeUri = item.enclosure?.attributes?.url,
           let safeType = item.enclosure?.attributes?.type,
           safeType.hasPrefix("image/") {
            return URL(string: safeUri)
        } else {
            print("No Media URIs found...")
        }
        return nil
    }
    
    private func getLinkUri(item: RSSFeedItem) -> URL? {
        if let safeLink = item.link {
            return URL(string: safeLink)
        }
        return nil
    }
    
    func generate(channelId: UUID, item: RSSFeedItem) -> UUID? {
        let a = getExistingOrNew(channelId: channelId, item: item)
        
        let title = item.title ?? "No title"
        let description = item.description ?? "No description"
        
        a.setValue(item.pubDate, forKey: "date")
        a.setValue(title, forKey: "title")
        a.setValue(description, forKey: "articleDescription")
        a.setValue(getLinkUri(item: item), forKey: "link")
        a.setValue(item.guid?.value, forKey: "guid")
        a.setValue(getCategoryString(categories: item.categories), forKey: "categories")
        a.setValue(item.author, forKey: "author")
        a.setValue(getContentString(item: item), forKey: "content")
        a.setValue(channelId, forKey: "channelId")
        a.setValue(getMediaUri(item: item), forKey: "mediaUri")
        
        let id = a.value(forKey: "id") as! UUID
        
        self.ctx.perform {
            do {
                try self.ctx.save()
            } catch {
                print("Failed saving article '" + id.uuidString + "'!")
            }
        }
        
        return id
    }
    
    func getByChannelId(channelId: UUID) -> [Article] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.predicate = NSPredicate(format: "channelId = %@", channelId.uuidString)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: !sortDescending)]
        request.returnsObjectsAsFaults = false
        do {
            let result = try ctx.fetch(request)
            return result as! [Article]
            
        } catch {
            print("Failed to find articles for channel with id '" + channelId.uuidString + "'")
        }
        return []
    }
    
    func markAsRead(article: Article, callback: @escaping () -> Void) {
        if let articleId = article.id {
            ctx.perform {
                let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id = %s", articleId.uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                do {
                    let results = try self.ctx.fetch(fetchRequest)
                    if let a = results.first {
                        a.read = true
                    }
                    try self.ctx.save()
                    print("Article marked as read...")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    callback()
                }
            }
        } else {
            print("Error: articleId is nil!")
            callback()
        }
        
    }
}
