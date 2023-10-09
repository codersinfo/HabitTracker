//
//  PersistenceController.swift
//  HabitTracker
//
//  Created by Priya Shankar on 28/09/23.
//

import Foundation
import CoreData
import SwiftUI

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    var newViewContext: NSManagedObjectContext {
        container.newBackgroundContext()
    }
    
    private init() {
        container = NSPersistentContainer(name: "HabitContainer")
        
        if EnvironmentValues.isPreview {
            container.persistentStoreDescriptions.first?.url = .init(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load Habit container \(error), \(error.userInfo)")
            }
        }
    }
}

extension EnvironmentValues {
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
