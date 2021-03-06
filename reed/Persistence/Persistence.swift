//
//  Persistence.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import CoreData
import SwiftUI

struct PersistenceController {
    
    @AppStorage("resetData") private var resetData = false
    
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Article(context: viewContext)
            newItem.date = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "reedModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        var shouldResetModel: Bool = resetData
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let _ = error as NSError? {
                print("Error loading data, probably a corrupt model!")
                shouldResetModel = true
            }
        })
        if(shouldResetModel) {
            print("Resetting data...")
            container.persistentStoreDescriptions.forEach({desc in
                do {
                    try container.persistentStoreCoordinator.destroyPersistentStore(at: desc.url!, ofType: NSSQLiteStoreType)
                    
                } catch {
                    print(error)
                }
            })
            // reload model
            container.loadPersistentStores(completionHandler: {(storeDescription, error) in
                if let e = error as NSError? {
                    fatalError(e.localizedDescription)
                }
            })
            if resetData {
                resetData = false
            }
        }
    }
}
