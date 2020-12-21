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
    @AppStorage("fontSize") private var fontSize = 12.0

    var body: some View {
        Form {
            Toggle("Show Images in Lists", isOn: $showImagesInList)
            Slider(value: $fontSize, in: 9...32) {
                Text("Font Size (\(fontSize, specifier: "%.0f") pts)")
            }
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}
