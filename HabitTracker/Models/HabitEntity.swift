//
//  HabitEntity.swift
//  HabitTracker
//
//  Created by Priya Shankar on 03/10/23.
//

import Foundation
import CoreData
import SwiftUI

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
    @NSManaged var createdAt: Date
    
    @NSManaged var weekDays: NSSet?
    @NSManaged var habitRecords: NSSet?
   
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
        // print(sortedArrays)
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

    static func getHabitDate(for targetDate: Date) -> NSFetchRequest<HabitEntity> {
        let request: NSFetchRequest<HabitEntity> = habitsFetchRequest
        request.relationshipKeyPathsForPrefetching = ["weekDays", "habitRecords"]
        //request.relationshipKeyPathsForPrefetching = ["habitRecords"]
        request.sortDescriptors = []
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: targetDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: targetDate)!
        print("startOfDay - \(startOfDay)\nendOfDay - \(targetDate)")
        print("filterDate - \(targetDate) \n")
        
        let weekDay = targetDate.getDay(format: "EEEE")
        print(weekDay)
        
        //MARK: Daily data Query
        ///Frequency must be Daily.
        ///Showing data based on selected Date if data is there.
        ///Showing already exist data with no end date but Start date should be not NULL.
        ///Showing already exist data till selected date less than End date.
        let dailyQuery = """
        frequency == [c] %@ AND ( 
        (startDate >= %@ AND startDate < %@) OR
        (startDate <= %@ AND (startDate != nil AND endDate == nil)) OR
        (endDate != nil AND startDate <= %@ AND endDate >= %@))
        """
        
        //MARK: Weekly data Query
        ///Frequency must be Weekly.
        ///Start date should be greater than or equal given date.
        ///End date can be less than or equal given date OR can be null too.
        let weeklyDataQuery = """
        frequency == [c] %@ AND ANY weekDays.day == [c] %@ AND (
        (startDate >= %@ AND startDate < %@) OR
        (startDate <= %@ AND endDate >= %@) OR 
        (startDate != nil AND endDate == nil))
        """
        
        //MARK: predicates
        let dailyPredicate = NSPredicate(format: dailyQuery, argumentArray: ["Daily", startOfDay as NSDate, endOfDay as NSDate, targetDate as NSDate, targetDate as NSDate, targetDate as NSDate])
        
        let weeklyPredicate = NSPredicate(format: weeklyDataQuery, argumentArray: ["Weekly", weekDay, startOfDay as NSDate, endOfDay as NSDate, targetDate as NSDate, targetDate as NSDate])
        
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [dailyPredicate, weeklyPredicate])
        return request
    }
    
    
    static func getHabitDate2(for targetDate: Date) -> NSFetchRequest<HabitEntity> {
        let request: NSFetchRequest<HabitEntity> = habitsFetchRequest
        request.relationshipKeyPathsForPrefetching = ["weekDays"]
        request.relationshipKeyPathsForPrefetching = ["habitRecords"]
        request.sortDescriptors = []
        
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: targetDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: targetDate)!
        print("startOfDay - \(startOfDay)\nendOfDay - \(targetDate)")
        print("filterDate - \(targetDate) \n")
        
        let weekDay = targetDate.getDay(format: "EEEE")
        print(weekDay)
        
        //MARK: Daily data Query
        ///Frequency must be Daily.
        ///Showing data based on selected Date if data is there.
        ///Showing already exist data with no end date but Start date should be not NULL.
        ///Showing already exist data till selected date less than End date.
        let dailyQuery = """
        frequency == [c] %@ AND (
        (startDate >= %@ AND startDate < %@) OR
        (startDate <= %@ AND (startDate != nil AND endDate == nil)) OR
        (endDate != nil AND startDate <= %@ AND endDate >= %@))
        """
        
        //MARK: Weekly data Query
        ///Frequency must be Weekly.
        ///Start date should be greater than or equal given date.
        ///End date can be less than or equal given date OR can be null too.
        let weeklyDataQuery = """
        frequency == [c] %@ AND ANY weekDays.day == [c] %@ AND (
        (startDate >= %@ AND startDate < %@) OR
        (startDate <= %@ AND endDate >= %@) OR
        (startDate != nil AND endDate == nil))
        """
        
        //MARK: predicates
        let dailyPredicate = NSPredicate(format: dailyQuery, argumentArray: ["Daily", startOfDay as NSDate, endOfDay as NSDate, targetDate as NSDate, targetDate as NSDate, targetDate as NSDate])
        
        let weeklyPredicate = NSPredicate(format: weeklyDataQuery, argumentArray: ["Weekly", weekDay, startOfDay as NSDate, endOfDay as NSDate, targetDate as NSDate, targetDate as NSDate])
        
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [dailyPredicate, weeklyPredicate])
        return request
    }
}


extension HabitEntity {
    @discardableResult
    static func makePreview(count: Int, in context: NSManagedObjectContext) -> [HabitEntity] {
        var habits = getDailyData(context: context)
        habits += getWeeklyData(context: context)
        // let habits = getWeeklyData(context: context)
        return habits
    }
    
    static func previewWithCount(context: NSManagedObjectContext = PersistenceController.shared.viewContext) -> HabitEntity {
        return makePreview(count: 1, in: context)[2]
    }
    
    static func previewWithTime(context: NSManagedObjectContext = PersistenceController.shared.viewContext) -> HabitEntity {
        return makePreview(count: 1, in: context)[3]
    }
    
    static func empty(context: NSManagedObjectContext = PersistenceController.shared.viewContext) -> HabitEntity {
        HabitEntity(context: context)
    }
}

//Preview sample Data
extension HabitEntity {
    static func getDailyData(context: NSManagedObjectContext) -> [HabitEntity] {
        var habits = [HabitEntity]()
        let habit = HabitEntity(context: context)
        habit.name = "Read books 30 mins a day"
        habit.note = "reading is good for concenrations"
        habit.icon = ""
        habit.color = "card-1"
        habit.goal = "0:03"
        habit.goalPeriod = "hoursMins"
        habit.frequency = "Daily"
        habit.timeRange = "Anytime"
        habit.startDate = Date()
        
        let habit2 = HabitEntity(context: context)
        habit2.name = "Read books"
        habit2.note = "reading is good for concenrations"
        habit2.icon = ""
        habit2.color = "card-2"
        habit2.goal = "3"
        habit2.goalPeriod = "count"
        habit2.frequency = "Daily"
        habit2.timeRange = "Anytime"
        habit2.startDate = .yesterday
        habit2.endDate = .tomorrow
        habits.append(habit2)
        
        let habit3 = HabitEntity(context: context)
        habit3.name = "Habit #3"
        habit3.note = "reading is good for concenrations"
        habit3.icon = ""
        habit3.color = "card-3"
        habit3.goal = "0:30"
        habit3.goalPeriod = "hoursMins"
        habit3.frequency = "Daily"
        habit3.timeRange = "Anytime"
        habit3.startDate = Date()
        habit3.endDate = .tomorrow
        habits.append(habit3)
        
        let habit4 = HabitEntity(context: context)
        habit4.name = "Habit #4"
        habit4.note = "reading is good for concenrations"
        habit4.icon = ""
        habit4.color = "card-4"
        habit4.goal = "10"
        habit4.goalPeriod = "count"
        habit4.frequency = "Daily"
        habit4.timeRange = "Anytime"
        habit4.startDate = .tomorrow
        habit4.endDate = .tomorrow.getDate(number: 2) //tomorrow + 2
        habits.append(habit4)
        
        let habit5 = HabitEntity(context: context)
        habit5.name = "Habit #5"
        habit5.note = "reading is good for concenrations"
        habit5.icon = ""
        habit5.color = "card-5"
        habit5.goal = "1:1:0"
        habit5.goalPeriod = "hoursMins"
        habit5.frequency = "Daily"
        habit5.timeRange = "Anytime"
        habit5.startDate = .tomorrow.getDate(number: 1) // tomorrow + 1
        habit5.endDate = .tomorrow.getDate(number: 3) // tomorrow + 3
        habits.append(habit5)
        return habits
    }
    
    static func getWeeklyData(context: NSManagedObjectContext) -> [HabitEntity] {
        var habits = [HabitEntity]()
        //MARK: Weekly habit #1
        let habit = HabitEntity(context: context)
        habit.name = "Weekly Data #1"
        habit.note = "Weekly Data"
        habit.icon = ""
        habit.color = "card-6"
        habit.goal = "30"
        habit.goalPeriod = "count"
        habit.frequency = "Weekly"
        habit.timeRange = "Anytime"
        habit.startDate = Date()
        
        var weekDays = [WeekDayEntity]()
        let weekday1 = WeekDayEntity(context: context)
        weekday1.day = "Monday"
        weekday1.habit = habit
        weekDays.append(weekday1)
        let weekday2 = WeekDayEntity(context: context)
        weekday2.day = "Wednesday"
        weekday2.habit = habit
        weekDays.append(weekday2)
        let weekday3 = WeekDayEntity(context: context)
        weekday3.day = "Friday"
        weekday3.habit = habit
        weekDays.append(weekday3)
        
        habit.weekDays = Set(weekDays) as NSSet
        habits.append(habit)
        
        //MARK: Weekly habit #2
        let habit2 = HabitEntity(context: context)
        habit2.name = "Weekly Data #2"
        habit2.note = "Weekly Data"
        habit2.icon = ""
        habit2.color = "card-7"
        habit2.goal = "0:5"
        habit2.goalPeriod = "hoursMins"
        habit2.frequency = "Weekly"
        habit2.timeRange = "Anytime"
        habit2.startDate = Date()
        
        var weekDays2 = [WeekDayEntity]()
        let weekdayH1 = WeekDayEntity(context: context)
        weekdayH1.day = "Tuesday"
        weekdayH1.habit = habit2
        weekDays2.append(weekdayH1)
        habit2.weekDays = Set(weekDays2) as NSSet
        habits.append(habit2)
        
        //MARK: Weekly habit #3
        let habit3 = HabitEntity(context: context)
        habit3.name = "Weekly Data #3"
        habit3.note = "Weekly Data"
        habit3.icon = ""
        habit3.color = "card-5"
        habit3.goal = "30"
        habit3.goalPeriod = "Mins"
        habit3.frequency = "Weekly"
        habit3.timeRange = "Anytime"
        habit3.startDate = Date()
        habit3.endDate = Date().getDate(number: 4)
        var weekDays3 = [WeekDayEntity]()
        let weekdayH3 = WeekDayEntity(context: context)
        weekdayH3.day = "Wednesday"
        weekdayH3.habit = habit3
        weekDays3.append(weekdayH3)
        
        let weekdayH32 = WeekDayEntity(context: context)
        weekdayH32.day = "Friday"
        weekdayH32.habit = habit3
        weekDays3.append(weekdayH32)
        
        habit3.weekDays = Set(weekDays3) as NSSet
        habits.append(habit3)
        
        //MARK: Weekly habit #4
        let habit4 = HabitEntity(context: context)
        habit4.name = "Weekly Data #4"
        habit4.note = "Weekly Data"
        habit4.icon = ""
        habit4.color = "card-4"
        habit4.goal = "30"
        habit4.goalPeriod = "Mins"
        habit4.frequency = "Weekly"
        habit4.timeRange = "Anytime"
        var weekNumber = Calendar.current.weekdaySymbols.firstIndex { weekDay in
            weekDay == "Sunday"
        } ?? -1
        weekNumber += 1
        print(weekNumber)
        print("Today Date - \(Date().dateForWeekday(weekNumber))")
        habit4.startDate = Date().dateForWeekday(weekNumber)
        
        var weekDays4 = [WeekDayEntity]()
        let weekdayH4 = WeekDayEntity(context: context)
        weekdayH4.day = "Friday"
        weekdayH4.habit = habit4
        weekDays4.append(weekdayH4)
        habit4.weekDays = Set(weekDays4) as NSSet
        habits.append(habit4)
        
        return habits
    }
}


#Preview {
    Group {
        let preview = PersistenceController.shared
        HabitListView(provider: preview)
            .environment(\.managedObjectContext, preview.viewContext)
            .onAppear {
                HabitEntity.makePreview(count: 5, in: preview.viewContext )
            }
    }
}


//extension HabitEntity {

//    static func getFilteredData(for filterDate: Date) -> NSFetchRequest<HabitEntity> {
//        let request: NSFetchRequest<HabitEntity> = habitsFetchRequest
//        request.sortDescriptors = []
//
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: filterDate)
//        // let endOfDay = calendar.date(byAdding: .day, value: 1, to: filterDate)!
//        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: filterDate)!
//        print("startOfDay - \(startOfDay)\nendOfDay - \(filterDate)")
//        print("filterDate - \(filterDate) \n")
//
//        //        let predicate1 = NSPredicate(format: "startDate >= %@ AND endDate <= %@", Date.yesterday as NSDate, Date.tomorrow as NSDate)
//        //        let predicate2 = NSPredicate(format: "startDate >= %@ AND startDate <= %@", startOfDay as NSDate, endOfDay as NSDate)
//        //        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
//
//        //get today created data whether its daily or weekly or monthly
//        let query = """
//        frequency == %@ AND (startDate >= %@ AND startDate < %@)
//        """
//        let getTodayDailyData = NSPredicate(format: query, "Daily", startOfDay as NSDate, endOfDay as NSDate)
//
//        //get already exists daily data but not today created data also check endDate already completed and ensure that data still havent reach the endDate
//        let query1 = """
//        frequency == %@ AND startDate <= %@
//        AND (startDate != nil AND endDate == nil)
//        """
//
//        let getExistDailyDataWithNoEndDate = NSPredicate(format: query1, "Daily", filterDate as NSDate)
//
//        //get already exist data if selected date is not end date
//        //Start date should be greater than or equal given date
//        //End date should be less than or equal given date
//        let query2 = """
//        frequency == %@ AND endDate != nil
//        AND startDate <= %@
//        AND endDate >= %@
//        """
//        let getExistDataWithEndDate = NSPredicate(format: query2, "Daily", filterDate as NSDate, filterDate as NSDate)
//
//
//        let dailyQuery = """
//        frequency == %@ AND (
//        (startDate >= %@ AND startDate < %@) OR
//        (startDate <= %@ AND (startDate != nil AND endDate == nil)) OR
//        (endDate != nil AND startDate <= %@ AND endDate >= %@)
//        )
//        """
//        let dailyPredicate = NSPredicate(format: dailyQuery, argumentArray: ["Daily", startOfDay as NSDate, endOfDay as NSDate, filterDate as NSDate, filterDate as NSDate, filterDate as NSDate])
//
//
//
//        //request.predicate = getTodayDailyData
//        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [getTodayDailyData, getExistDailyDataWithNoEndDate, getExistDataWithEndDate])
//        //request.predicate = predicate2
//
//        return request
//    }
    
//    static func getFilteredDataForWeekly(for filterDate: Date) -> NSFetchRequest<HabitEntity> {
//        let request: NSFetchRequest<HabitEntity> = habitsFetchRequest
//        request.relationshipKeyPathsForPrefetching = ["weekDays"]
//
//        let weekDay = filterDate.getDay(format: "EEEE")
//        print(weekDay)
//
//        request.sortDescriptors = []
//
//        //Start date should be greater than or equal given date
//        //End date should be less than or equal given date
//        //        let query1 = """
//        //        frequency == %@ AND ANY weekDays.day == [c] %@ AND
//        //        startDate <= %@ AND endDate >= %@
//        //        """
//        //        let getWeeklyDataWithDates = NSPredicate(format: query1, "Weekly", weekDay, filterDate as NSDate, filterDate as NSDate) //[C] = Case Insensitive
//
//        //Start date should be greater than or equal given date
//        //End date can be null too
//        //        let query2 = """
//        //        frequency == %@ AND ANY weekDays.day == [c] %@ AND
//        //        (startDate != nil AND endDate == nil)
//        //        """
//
//        //let getWeeklyDataWithoutEndDate = NSPredicate(format: query2, "Weekly", weekDay)
//
//        ///Frequency must be Weekly
//        ///Start date should be greater than or equal given date
//        ///End date can be less than or equal given date OR can be null too
//        let weeklyDataQuery = """
//        frequency == %@ AND ANY weekDays.day == [c] %@ AND
//        (startDate <= %@ AND endDate >= %@ OR startDate != nil AND endDate == nil)
//        """
//        let weeklyPredicate = NSPredicate(format: weeklyDataQuery, argumentArray: ["Weekly", weekDay, filterDate as NSDate, filterDate as NSDate])
//
//        //        let weeklyPredicate =  NSPredicate(format: weeklyDataQuery, "Weekly", weekDay, filterDate as NSDate, filterDate as NSDate)
//
//        //let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [getWeeklyDataWithDates, getWeeklyDataWithoutEndDate])
//        request.predicate = weeklyPredicate
//
//        return request
//    }

//}
