//
//  AdvancedSettingsView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI
import Darwin

struct AdvancedSettingsView: View {
    
    @AppStorage("resetData") private var resetData = false
    
    let persistenceProvider: PersistenceProvider
    
    @State private var showingConfirmationAlert = false

    var body: some View {
        VStack {
            Button(action: {
                showingConfirmationAlert = true
            }, label: {
                Text("Delete all stored data...")
            }).alert(isPresented: $showingConfirmationAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Are you sure you want to delete all data stored by the app?\nThe app will quit afterwards."),
                    primaryButton: .default(Text("Yes"), action: {() -> Void in
                        resetData = true
                        persistenceProvider.resetDatabase()
                        persistenceProvider.save {
                            exit(0)
                        }
                    }),
                    secondaryButton: .default(Text("No"), action: {()->Void in
                        self.showingConfirmationAlert = false
                    }))
            }
        }
    }
}
