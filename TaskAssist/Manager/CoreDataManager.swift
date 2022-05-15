//
//  CoreDataManager.swift
//  TaskAssist
//
//  Created by Viraj Lakshitha Bandara on 2022-05-15.
//

import Foundation
import CoreData

class CoreDataManager {
    let persistenceContainer : NSPersistentContainer
    static let shared: CoreDataManager = CoreDataManager()
    
    private init() {
        persistenceContainer = NSPersistentContainer(name: "TaskAssitModel") // This should be same as model file name
        persistenceContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to initialize Core Data \(error)")
            }
        }
    }
}
