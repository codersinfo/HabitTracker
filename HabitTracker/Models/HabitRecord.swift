//
//  HabitRecord.swift
//  HabitTracker
//
//  Created by Priya Shankar on 17/10/23.
//

import Foundation
import CoreData

final class HabitRecord: NSManagedObject, Identifiable {
    @NSManaged public var date: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var progress: String?
    @NSManaged public var habit: HabitEntity?
}

extension HabitRecord {
    private static var habitsRecordFetchRequest: NSFetchRequest<HabitRecord> {
        NSFetchRequest(entityName: "HabitRecord")
    }
    
//    static func fetchHabitRecord(date: Date, habit: HabitEntity) {
//        let request = getHabitRecordForDate(date: date, habit: habit)
//        request.fetchLimit = 1
//        
//        do {
//            try
//        }
//    }
    
    static func getHabitRecordForDate(date: Date, habit: HabitEntity) -> NSFetchRequest<HabitRecord> {
        let request: NSFetchRequest<HabitRecord> = habitsRecordFetchRequest
        request.sortDescriptors = []
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        
        request.predicate = NSPredicate(format: "(date >= %@ AND date < %@) AND habit == %@", argumentArray: [startOfDay as NSDate, endOfDay as NSDate, habit])
        return request
    }
}

