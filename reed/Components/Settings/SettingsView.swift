//
//  SettingsView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    var persistenceProvider: PersistenceProvider
    var refresh: () -> Void
    
    private enum Tabs: Hashable {
        case general, channels, advanced
    }
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            ChannelSettingsView(persistenceProvider: persistenceProvider, refresh: refresh)
                .tabItem {
                    Label("Channels", systemImage: "network")
                }
                .tag(Tabs.channels)
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
                .tag(Tabs.advanced)
        }
        .padding(8)
        .frame(width: 800, height: 600)
    }
}
