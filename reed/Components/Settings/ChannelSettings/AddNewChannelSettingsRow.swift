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
    
    @State private var showingDialog: Bool = false
    @State private var newChannelUrl: String = ""
    @State private var alertMessage: String = "Fetching information..."
    
    var persistenceProvider: PersistenceProvider
    var retrieveChannels: () -> Void
    
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
                                    persistenceProvider.persistFeed(feed: feed, feedUrl: feedUrl)
                                    
                                    newChannelUrl = ""
                                    break
                                default:
                                    alertMessage = "Currently only RSS is supported!"
                                    break
                                }
                                
                                
                                DispatchQueue.main.async {
                                    persistenceProvider.save(callback: {() -> Void in
                                        // Refresh UI
                                        retrieveChannels()
                                        self.showingDialog = false
                                    })
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
