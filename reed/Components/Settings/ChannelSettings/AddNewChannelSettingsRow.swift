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
    @State private var showingLoader: Bool = false
    @State private var newChannelUrl: String = ""
    @State private var alertMessage: String = "Fetching information..."
    
    var persistenceProvider: PersistenceProvider
    var retrieveChannels: () -> Void
    
    var body: some View {
        VStack {
            Text("Add a new Channel").font(.headline)
            HStack {
                if showingLoader {
                    HStack {
                        ProgressView()
                            .frame(width: 32, height: 32)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                } else {
                    TextField("Feed URL", text: $newChannelUrl)
                    Spacer()
                    Button(action: {
                        self.showingLoader = true
                        
                        let inputUrl = URL(string: newChannelUrl)
                        
                        if let feedUrl = inputUrl {
                            FeedUtils(persistenceProvider: persistenceProvider).fetchAndPersistFeed(feedUrl: feedUrl, callback: { error in
                                if let safeError = error {
                                    alertMessage = safeError
                                    showingDialog = true
                                }
                                newChannelUrl = ""
                                retrieveChannels()
                                showingLoader = false
                            })
                        } else {
                            // TODO: show error
                            showingLoader = false
                            showingDialog = true
                        }
                        
                    }, label: {
                        Text("+")
                    })
                    .alert(isPresented: $showingDialog) {
                        Alert(
                            title: Text("Error!"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("Ok"), action: {
                                showingDialog = false
                            })
                        )
                    }
                }
            }
        }
    }
}
