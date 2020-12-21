//
//  ChannelSettingsView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ChannelSettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var channels: Array<Channel> = []
   
    var body: some View {
        List(channels, id: \.id) { channel in
            ChannelSettingsRow(channel: channel)
        }
        .padding(8)
        .onAppear(perform: retrieveChannels)
    }
    
    func retrieveChannels() -> Void {
        self.channels = []
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.returnsObjectsAsFaults = false
        do {
            let result = try viewContext.fetch(request)
            self.channels = result as! [Channel]
        } catch {
            print("Failed to get channels!")
        }
    }
}
