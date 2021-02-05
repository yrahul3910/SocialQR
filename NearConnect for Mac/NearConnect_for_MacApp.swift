//
//  NearConnect_for_MacApp.swift
//  NearConnect for Mac
//
//  Created by Rahul Yedida on 1/21/21.
//

import SwiftUI

@main
struct NearConnect_for_MacApp: App {
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
