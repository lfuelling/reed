//
//  AddNewChannelSettingsRow.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI
import FeedKit

struct AddNewChannelSettingsRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingDialog: Bool = false
    @State private var newChannelUrl: String = ""
    @State private var alertMessage: String = "Fetching information..."
    
    var retrieveChannels: () -> Void
    
    func generateChannelImage(feed: RSSFeed) -> UUID? {
        if(feed.image != nil) {
            let channelImageEntity = NSEntityDescription.entity(forEntityName: "ChannelImage", in: viewContext)
            let ci = NSManagedObject(entity: channelImageEntity!, insertInto: viewContext)
            let id = UUID()
            ci.setValue(id, forKey: "id")
            ci.setValue(feed.image?.url, forKey: "url")
            ci.setValue(feed.image?.title, forKey: "title")
            ci.setValue(feed.image?.link, forKey: "link")
            do {
                try viewContext.save()
            } catch {
                print("Failed saving ChannelImage with id '" + id.uuidString + "'!")
            }
            return id
        }
        return nil
    }
    
    func generateChannel(feedURL: URL, imageId: UUID?, feed: RSSFeed) -> UUID {
        let channelEntity = NSEntityDescription.entity(forEntityName: "Channel", in: viewContext)
        let c = NSManagedObject(entity: channelEntity!, insertInto: viewContext)
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
           try viewContext.save()
          } catch {
            print("Failed saving Channel with id '" + id.uuidString + "'!")
        }
        return id
    }
    
    var body: some View {
        VStack {
            Text("Add a new Channel").font(.headline)
            HStack {
                TextField("Feed URL", text: $newChannelUrl)
                Spacer()
                Button(action: {
                    self.showingDialog = true
                    
                    let inputUrl = URL(string: newChannelUrl)
                    
                    
                    if let feedUrl = inputUrl {
                        let parser = FeedParser(URL: feedUrl)
                        
                        // Parse asynchronously, not to block the UI.
                        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) {(result) in
                            
                            switch result {
                            case .success(let feed):
                                switch feed {
                                case .rss(let feed):
                                    let imageId: UUID? = generateChannelImage(feed: feed)
                                    let channelId: UUID = generateChannel(feedURL: feedUrl, imageId: imageId, feed: feed)
                                    print("Successfully created channel '" + channelId.uuidString + "'!")
                                    newChannelUrl = ""
                                    break
                                default:
                                    alertMessage = "Currently only RSS is supported!"
                                    break
                                }
                                
                                
                                DispatchQueue.main.async {
                                    // Refresh UI
                                    retrieveChannels()
                                    self.showingDialog = false
                                }
                                
                            case .failure(let error):
                                print(error)
                                alertMessage = "Error parsing feed!"
                            }
                        }
                        
                    } else {
                        // TODO: show error
                    }
                    
                }, label: {
                    Text("+")
                }).alert(isPresented: $showingDialog) {
                    Alert(
                        title: Text("Adding new Channel..."),
                        message: Text(alertMessage))
                }
            }
        }
    }
}
