//
//  ChannelSettingsRow.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ChannelSettingsRow: View {
    
    @State private var showingDeletionConfirmation = false
    
    var channel: Channel
    var persistenceProvider: PersistenceProvider
    var retrieveChannels: () -> Void
    
    var body: some View {
        if(channel.updateUri == nil) {
            Text("Error")
        } else {
            HStack {
                Text(channel.title!).font(.headline)
                if let safeUri = channel.updateUri {
                    Text(safeUri.absoluteString)
                }
                Spacer()
                if let safeLink = channel.link {
                    Button(action: {
                        if !NSWorkspace.shared.open(safeLink) {
                            print("Error opening link: '" + safeLink.absoluteString + "'!")
                        }
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                }
                Button(action: {
                    self.showingDeletionConfirmation = true
                }, label: {
                    Image(systemName: "trash")
                }).alert(isPresented: $showingDeletionConfirmation) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("Are you sure you want to delete the channel '" + channel.title! + "'?"),
                        primaryButton: .default(Text("Yes"), action: {() -> Void in
                            persistenceProvider.deleteChannel(channel: channel)
                            self.showingDeletionConfirmation = false
                            retrieveChannels()
                        }),
                        secondaryButton: .default(Text("No"), action: {()->Void in
                            self.showingDeletionConfirmation = false
                        }))
                }
            }
        }
    }
}
