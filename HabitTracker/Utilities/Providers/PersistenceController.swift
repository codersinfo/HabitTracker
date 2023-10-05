//
//  PersistenceController.swift
//  HabitTracker
//
//  Created by Priya Shankar on 28/09/23.
//

import Foundation
import CoreData

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
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load Habit container \(error), \(error.userInfo)")
            }
        }
    }
}
