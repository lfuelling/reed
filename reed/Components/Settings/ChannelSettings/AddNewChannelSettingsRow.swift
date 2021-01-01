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
                        FeedUtils(persistenceProvider: persistenceProvider).fetchAndPersistFeed(feedUrl: feedUrl, callback: {
                            newChannelUrl = ""
                            retrieveChannels()
                        })
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
