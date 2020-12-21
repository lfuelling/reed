//
//  ChannelSettingsRow.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ChannelSettingsRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingDeletionConfirmation = false
    
    var channel: Channel
    var retrieveChannels: () -> Void
    
    var body: some View {
        HStack {
            Text(channel.title!).font(.headline)
            Text(channel.link!)
            Spacer()
            Button(action: {
                self.showingDeletionConfirmation = true
            }, label: {
                Text("􀈑")
            }).alert(isPresented: $showingDeletionConfirmation) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Are you sure you want to delete the channel '" + channel.title! + "'?"),
                    primaryButton: .default(Text("Yes"), action: {() -> Void in
                        viewContext.delete(channel)
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
