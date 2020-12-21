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
           print("Failed saving first ChannelImage")
        }
        return id
    }
    
    
    let dummyChannelOne = {() -> Void in
        let channelEntity = NSEntityDescription.entity(forEntityName: "Channel", in: context)
        var c = NSManagedObject(entity: channelEntity!, insertInto: context)
        
        c.setValue("Some Author's Blog", forKey: "title")
        c.setValue("A simple blog.", forKey: "channelDescription")
        c.setValue("https://127.0.0.1/", forKey: "link")
        c.setValue(generateChannelOneImage(), forKey: "channelImageId")
        c.setValue("Some Software", forKey: "generator")
        c.setValue("Mon, 21 Dec 2020 00:01:01 GMT", forKey: "lastBuildDate")
        c.setValue(60, forKey: "ttl")
        c.setValue("http://127.0.0.1/rss", forKey: "updateUri")
        do {
           try context.save()
          } catch {
           print("Failed saving first ChannelImage")
        }
    }

    /*let dummyChannelTwoImage = {() -> ChannelImage in
        var ci = ChannelImage()
        ci.url = "http://127.0.1.1/favicon.ico"
        ci.title = "Favicon"
        ci.link = "http://127.0.1.1/"
        return ci
    }
    let dummyChannelTwo = {() -> Channel in
        var c  = Channel()
        c.title = "Some Other Author's Blog"
        c.channelDescription = "Another simple blog."
        c.link = "https://127.0.1.1/"
        c.image = dummyChannelTwoImage()
        c.generator = "Some other Software"
        c.lastBuildDate = "Mon, 21 Dec 2020 00:01:01 GMT"
        c.ttl = 60
        c.updateUri = "http://127.0.1.1/rss"
        return c
    }

    let dummyArticleOne = {() -> Article in
        var a = Article()
        a.date = Date()
        a.title = "Hello World!"
        a.articleDescription = "A simple Hello World article."
        a.link = "http://127.0.0.1/hello"
        a.guid = "wertzuiuztrd"
        a.categories = "[\"Hello\", \"World\"]"
        a.author = "Some Author"
        a.content = "This is a simple hello world article. Hello world."
        a.mediaUris = "[\"http://127.0.0.1/favicon.ico\"]"
        a.channelId = dummyChannelOne().id
        return a
    }

    let dummyArticleTwo = {() -> Article in
        var a = Article()
        a.date = Date()
        a.title = "Also Hello World!"
        a.articleDescription = "Another simple Hello World article."
        a.link = "http://127.0.1.1/hello"
        a.guid = "wertauiuztrd"
        a.categories = "[\"Hello\", \"World\"]"
        a.author = "Some Author"
        a.content = "This is another simple hello world article. Hello world."
        a.mediaUris = "[\"http://127.0.1.1/favicon.ico\"]"
        a.channelId = dummyChannelTwo().id
        return a
    }*/
}
