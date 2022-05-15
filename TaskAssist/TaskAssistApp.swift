//
//  TaskAssistApp.swift
//  TaskAssist
//
//  Created by Viraj Lakshitha Bandara on 2022-05-15.
//

import SwiftUI

@main
struct TaskAssistApp: App {
    let persistenceContainer = CoreDataManager.shared.persistenceContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceContainer.viewContext)
        }
    }
}
