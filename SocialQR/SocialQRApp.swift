//
//  SocialQRApp.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/16/20.
//

import SwiftUI
import CoreData

// From https://stackoverflow.com/a/62067616
class ObservableBool: ObservableObject {
    @Published var value: Bool = true
    
    func setTrue() {
        self.value = true
    }
    
    func setFalse() {
        self.value = false
    }
}

@main
struct SocialQRApp: App {
    var userPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let userContext = userPersistentContainer.viewContext
        if userContext.hasChanges {
            do {
                try userContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, userPersistentContainer.viewContext)
        }
    }
}
