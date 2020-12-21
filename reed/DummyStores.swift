//
//  DummyStores.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import CoreData

let generateDummyData = {(context: NSManagedObjectContext) -> Void in
    
    let generateChannelOneImage = {() -> UUID in
        let channelImageEntity = NSEntityDescription.entity(forEntityName: "ChannelImage", in: context)
        var ci = NSManagedObject(entity: channelImageEntity!, insertInto: context)
        let id = UUID()
        ci.setValue(id, forKey: "id")
        ci.setValue("http://127.0.0.1/favicon.ico", forKey: "url")
        ci.setValue("Favicon", forKey: "title")
        ci.setValue("http://127.0.0.1/", forKey: "link")
        do {
           try context.save()
          } catch {
           print("Failed saving first ChannelImage!")
        }
        return id
    }
    
    
    let generateDummyChannelOne = {() -> UUID in
        let channelImageId = generateChannelOneImage()
        let channelEntity = NSEntityDescription.entity(forEntityName: "Channel", in: context)
        var c = NSManagedObject(entity: channelEntity!, insertInto: context)
        let id = UUID()
        
        c.setValue(id, forKey: "id")
        c.setValue("Some Author's Blog", forKey: "title")
        c.setValue("A simple blog.", forKey: "channelDescription")
        c.setValue("https://127.0.0.1/", forKey: "link")
        c.setValue(channelImageId, forKey: "channelImageId")
        c.setValue("Some Software", forKey: "generator")
        c.setValue("Mon, 21 Dec 2020 00:01:01 GMT", forKey: "lastBuildDate")
        c.setValue(60, forKey: "ttl")
        c.setValue("http://127.0.0.1/rss", forKey: "updateUri")
        do {
           try context.save()
          } catch {
           print("Failed saving first Channel!")
        }
        return id
    }

    let generateChannelTwoImage = {() -> UUID in
        let channelImageEntity = NSEntityDescription.entity(forEntityName: "ChannelImage", in: context)
        var ci = NSManagedObject(entity: channelImageEntity!, insertInto: context)
        let id = UUID()
        ci.setValue(id, forKey: "id")
        ci.setValue("http://127.0.1.1/favicon.ico", forKey: "url")
        ci.setValue("Favicon", forKey: "title")
        ci.setValue("http://127.0.1.1/", forKey: "link")
        do {
           try context.save()
          } catch {
           print("Failed saving second ChannelImage!")
        }
        return id
    }
    
    let generateDummyChannelTwo = {() -> UUID in
        let channelImageId = generateChannelTwoImage()
        let channelEntity = NSEntityDescription.entity(forEntityName: "Channel", in: context)
        var c = NSManagedObject(entity: channelEntity!, insertInto: context)
        let id = UUID()
        
        c.setValue(id, forKey: "id")
        c.setValue("Some Other Author's Blog", forKey: "title")
        c.setValue("Another simple blog.", forKey: "channelDescription")
        c.setValue("https://127.0.1.1/", forKey: "link")
        c.setValue(channelImageId, forKey: "channelImageId")
        c.setValue("Some other Software", forKey: "generator")
        c.setValue("Mon, 21 Dec 2020 00:01:01 GMT", forKey: "lastBuildDate")
        c.setValue(60, forKey: "ttl")
        c.setValue("http://127.0.1.1/rss", forKey: "updateUri")
        do {
           try context.save()
          } catch {
           print("Failed saving second Channel!")
        }
        return id
    }

    let generateDummyArticleOne = {() -> UUID in
        let channelId = generateDummyChannelOne()
        let articleEntity = NSEntityDescription.entity(forEntityName: "Article", in: context)
        var a = NSManagedObject(entity: articleEntity!, insertInto: context)
        let id = UUID()
        
        a.setValue(id, forKey: "id")
        a.setValue(Date(), forKey: "date")
        a.setValue("Hello World!", forKey: "title")
        a.setValue("A simple Hello World article.", forKey: "articleDescription")
        a.setValue("http://127.0.0.1/hello", forKey: "link")
        a.setValue("wertzuiuztrd", forKey: "guid")
        a.setValue("[\"Hello\", \"World\"]", forKey: "categories")
        a.setValue("Some Author", forKey: "author")
        a.setValue("This is a simple hello world article. Hello world.", forKey: "content")
        a.setValue("[\"http://127.0.0.1/favicon.ico\"]", forKey: "mediaUris")
        a.setValue(channelId, forKey: "channelId")
        do {
           try context.save()
          } catch {
           print("Failed saving first Article!")
        }
        return id
    }

    let generateDummyArticleTwo = {() -> UUID in
        let channelId = generateDummyChannelTwo()
        let articleEntity = NSEntityDescription.entity(forEntityName: "Article", in: context)
        var a = NSManagedObject(entity: articleEntity!, insertInto: context)
        let id = UUID()
        
        a.setValue(id, forKey: "id")
        a.setValue(Date(), forKey: "date")
        a.setValue("Hello again, World!", forKey: "title")
        a.setValue("Another simple Hello World article.", forKey: "articleDescription")
        a.setValue("http://127.0.1.1/hello", forKey: "link")
        a.setValue("wertzuiffztrd", forKey: "guid")
        a.setValue("[\"Hello\", \"World\"]", forKey: "categories")
        a.setValue("Some other Author", forKey: "author")
        a.setValue("This is another simple hello world article. Hello world.", forKey: "content")
        a.setValue("[\"http://127.0.1.1/favicon.ico\"]", forKey: "mediaUris")
        a.setValue(channelId, forKey: "channelId")
        do {
           try context.save()
          } catch {
           print("Failed saving first Article!")
        }
        return id
    }
    
    print("Generated first article as: " + generateDummyArticleOne().uuidString)
    print("Generated first article as: " + generateDummyArticleTwo().uuidString)
}
