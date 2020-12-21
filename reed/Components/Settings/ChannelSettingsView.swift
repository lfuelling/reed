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
    
    @State var channels: Array<Channel>? = nil
   
    var body: some View {
        ChannelNSTable(
            channels: self.$channels
        )
        .padding(20)
        .frame(width: 350, height: 100)
        .onAppear(perform: retrievePlayers)
    }
    
    func retrievePlayers() -> Void {
        self.channels = nil
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        request.returnsObjectsAsFaults = false
        do {
            let result = try viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
               print(data.value(forKey: "title") as! String)
          }
            
        } catch {
            print("Failed to get channels!")
        }
    }
}
