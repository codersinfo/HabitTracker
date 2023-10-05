//
//  HabitEntity.swift
//  HabitTracker
//
//  Created by Priya Shankar on 03/10/23.
//

import Foundation
import CoreData

final class HabitEntity: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var note: String?
    @NSManaged var icon: String
    @NSManaged var color: String
    @NSManaged var goal: String?
    @NSManaged var goalPeriod: String?
    @NSManaged var frequency: String
    @NSManaged var timeRange: String
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date?
   // @NSManaged var isRepeat: Bool
    @NSManaged var isRemainderOn: Bool
    @NSManaged var remainderText: String?
    @NSManaged var notificationTime: Date?
    @NSManaged var isCompleted: Bool
    @NSManaged var weekDays: NSSet?
    @NSManaged var createdAt: Date
    //@NSManaged var updatedAt: Date

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(false, forKey: "isCompleted")
        setPrimitiveValue("card-1", forKey: "color")
        setPrimitiveValue(Date.now, forKey: "createdAt")
    }
    
    public var weekdayArray: [WeekDayEntity] {
        let set = weekDays as? Set<WeekDayEntity> ?? []
        let sortedArrays = set.sorted(by: { $0.day == $1.day })
        print(sortedArrays)
        return sortedArrays
    }
}


extension HabitEntity {
    private static var habitsFetchRequest: NSFetchRequest<HabitEntity> {
        NSFetchRequest(entityName: "HabitEntity")
    }
    
    static func all() -> NSFetchRequest<HabitEntity> {
        let request: NSFetchRequest<HabitEntity> = habitsFetchRequest
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitEntity.name, ascending: true)]
        return request
    }
}
