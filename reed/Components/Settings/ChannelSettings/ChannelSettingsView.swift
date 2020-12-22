//
//  ChannelSettingsView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ChannelSettingsView: View {
    
    var persistenceProvider: PersistenceProvider
    
    var refresh: () -> Void
    
    @State var channels: Array<Channel> = []
   
    var body: some View {
        VStack {
            List(channels, id: \.id) { channel in
                ChannelSettingsRow(channel: channel, persistenceProvider: persistenceProvider, retrieveChannels: retrieveChannels)
            }.listStyle(InsetListStyle())
            AddNewChannelSettingsRow(persistenceProvider: persistenceProvider, retrieveChannels: retrieveChannelsAndRefresh)
        }
        .padding(8)
        .onAppear(perform: retrieveChannels)
        
    }
    
    func retrieveChannels() -> Void {
        self.channels = persistenceProvider.channels.getAll()
    }
    
    func retrieveChannelsAndRefresh() -> Void {
        retrieveChannels()
        refresh()
    }
}
