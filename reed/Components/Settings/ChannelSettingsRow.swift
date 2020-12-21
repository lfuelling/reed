//
//  ChannelSettingsRow.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ChannelSettingsRow: View {
    var channel: Channel

    var body: some View {
        HStack {
            Text(channel.title!).font(.headline)
            Spacer()
            Text(channel.link!)
        }
    }
}
