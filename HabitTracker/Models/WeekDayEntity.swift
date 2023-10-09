//
//  WeekDayEntity.swift
//  HabitTracker
//
//  Created by Priya Shankar on 03/10/23.
//

import Foundation
import CoreData

final class WeekDayEntity: NSManagedObject, Identifiable {
    @NSManaged public var createdAt: Date?
    @NSManaged public var day: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var notificationID: String?
    @NSManaged public var habit: HabitEntity?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date.now, forKey: "createdAt")
    }
}

extension WeekDayEntity {
    private static var weekDayFetchRequest: NSFetchRequest<WeekDayEntity> {
        NSFetchRequest(entityName: "WeekDayEntity")
    }
    
    public static func all(myhabit: HabitEntity) -> NSFetchRequest<WeekDayEntity> {
        let request: NSFetchRequest<WeekDayEntity> = weekDayFetchRequest
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "habit =%@", myhabit)
        return request
    }
}


extension WeekDayEntity {
    
}
