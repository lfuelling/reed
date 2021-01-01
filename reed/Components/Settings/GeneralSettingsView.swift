//
//  GeneralSettingsView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("showImagesInList") private var showImagesInList = true
    @AppStorage("sortDescending") private var sortDescending = true
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("descriptionMaxLines") private var descriptionMaxLines = 3.0
    
    var body: some View {
        Form {
            VStack (alignment: .leading) {
                Toggle("Sort New Articles To The Top", isOn: $sortDescending)
                Toggle("Show Icons In Lists", isOn: $showImagesInList)
                Slider(value: $fontSize, in: 9...32) {
                    Text("Font Size (\(fontSize, specifier: "%.0f") pts)")
                }
                Stepper(value: $descriptionMaxLines, in: 1...5) {
                    Text("Max Lines Of Description: \(descriptionMaxLines, specifier: "%.0f")")
                }
            }
        }
    }
}
