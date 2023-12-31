//
//  AddNewHabitViewModel.swift
//  HabitTracker
//
//  Created by Priya Shankar on 30/09/23.
//

import Foundation
import Observation
import CoreData
import UserNotifications
import SwiftUI

@Observable
class AddNewHabitViewModel {
    var name: String = ""
    var note: String = ""
    var icon: String = "book"
    var color: String = "card-1"
    var hasGoalSet: Bool = false
    var goal: String = "1"
    var goalPeriod: GoalUnitType = .count
    var timeRange: TimeRange = .anytime
    var frequency: Frequency = .daily
    var isRepeat: Bool = false
    var savedWeekDays: [String] = ["Sunday"]
    var remainderOn: Bool = false
    var remainderText: String = ""
    var remainderDate: Date = .now
    var startDate: Date = Date()
    var hasEndDateEnabled: Bool = false
    var endDate: Date = Date()
    var hours: String?
    var mins: String?
    var isNew: Bool
    private var goalTime: String {
        "\(hours ?? "0"):\(mins ?? "0"):0"
    }
    private var habit: HabitEntity
    // private var weekDays: WeekDayEntity? = nil
    
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    //    init(context: PersistenceController, habit: HabitEntity? = nil) {
    //        self.context = context.newViewContext
    //        self.habit = HabitEntity(context: self.context)
    //       // self.weekDays = WeekDayEntity(context: self.context)
    //    }
    
    init(provider: PersistenceController, habit: HabitEntity? = nil) {
        self.context = provider.newViewContext
        if let habit, let existingHabit = try? context.existingObject(with: habit.objectID) as? HabitEntity {
            self.habit = existingHabit
            self.isNew = false
            setHbaitData()
        } else {
            self.habit = HabitEntity(context: self.context)
            self.isNew = true
        }
        // self.weekDays = WeekDayEntity(context: self.context)
    }
    
    func setHbaitData() {
        self.name = habit.name
        self.note = habit.note ?? ""
        self.icon = habit.icon
        self.color = habit.color
        self.goal = habit.goal ?? ""
        self.goalPeriod = GoalUnitType(rawValue: habit.goalPeriod ?? "") ?? .count
        self.timeRange = .anytime
        self.frequency = .daily
        //isRepeat = false
       // savedWeekDays = ["Sunday"]
        self.remainderOn = false
        self.remainderText = habit.remainderText ?? ""
        self.remainderDate = habit.notificationTime ?? .now
        self.startDate = habit.startDate
        //hasEndDateEnabled = false
        //endDate = Date()
        //    hours
        //    mins
    }

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func addNewHabitForDaily() async throws {
        habit.name = name
        habit.note = note
        habit.color = color
        habit.icon = icon
        habit.timeRange = timeRange.rawValue.capitalized
        habit.frequency = frequency.rawValue.capitalized
        habit.startDate = startDate
        
        //MARK: Goal
        if hasGoalSet {
            if goalPeriod == .hoursMins {
                if hours == "0" && mins == "0" {
                    
                } else {
                    print(goalTime)
                    habit.goal = goalTime
                }
            } else {
                if !goal.isEmpty {
                    habit.goal = goal
                }
            }
            habit.goalPeriod = goalPeriod.rawValue
        } else {
            //Set default values
            habit.goal = goal
            habit.goalPeriod = goalPeriod.rawValue
        }
        
        if frequency == .weekly {
            if savedWeekDays.count != 0 {
                let weekDays = getWeekDayEntity()
                self.habit.weekDays = Set(weekDays) as NSSet
            } else {
                //Validations
            }
        }
        
        //MARK: Remainder
        if remainderOn {
            if !remainderText.isEmpty {
                habit.isRemainderOn = remainderOn
                habit.remainderText = remainderText
                habit.notificationTime = remainderDate
                
                if hasEndDateEnabled {
                    switch frequency {
                    case .daily:
                        try await scheduleNotifcationWithEndDate()
                    case .weekly:
                        scheduleNotificationWeeklyWithEndDate()
                    case .monthly:
                        break
                    }
                }
                else {
                    switch frequency {
                    case .daily:
                        try await scheduleNotificationForDailyWithoutEndDate()
                    case .weekly:
                        scheduleNotificationWeekday()
                    case .monthly:
                        break
                    }
                }
            } else {
                //Validation
            }
        }
        
        //MARK: End Date
        if hasEndDateEnabled {
            habit.endDate = endDate
        } else {
            habit.endDate = nil
        }
        
        try save()
    }
    
    private func getWeekDayEntity() -> [WeekDayEntity] {
        var weekDayEntities = [WeekDayEntity]()
        //let weekDaySymbols = calendar.weekdaySymbols
        
        for weekDay in savedWeekDays {
            let weekDayEntity = WeekDayEntity(context: self.context)
            weekDayEntity.day = weekDay
            weekDayEntity.habit = self.habit
            
            weekDayEntities.append(weekDayEntity)
        }
        
        return weekDayEntities
    }
}

//MARK: Notification
private extension AddNewHabitViewModel {
    /// Get the base date components
    private func getNotificationDateComponents() -> DateComponents {
        //let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: remainderDate)
        dateComponents.minute = calendar.component(.minute, from: remainderDate)
        
        return dateComponents
    }
    
    ///Get notification content
    private func getContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = name
        content.subtitle = remainderText
        content.sound = .default
        
        return content
    }
    
    ///Trigger Notification based on DateComponents
    private func triggerNotification(for dateComponent: DateComponents, notificationId: String) async throws {
        let content = getContent()
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}


//MARK: Scheduling notifications
private extension AddNewHabitViewModel {
    ///Schedule notification for daily
    @discardableResult
    private func scheduleNotificationForDailyWithoutEndDate() async throws -> Bool {
        let dateComponents = getNotificationDateComponents()
        let id = UUID().uuidString
        
        if let _ = try? await triggerNotification(for: dateComponents, notificationId: id) {
            return true
        }
        
        return false
    }
    
    ///Scheduling notification for everyday with end date.
    private func scheduleNotifcationWithEndDate() async throws {
        print("End Date - \(endDate)")
        //let calendar = Calendar.current
        var currentDate = startDate
        let content = getContent()
        
        while currentDate <= endDate {
            //Create date components for current date
            var dateComponents = getNotificationDateComponents()
            dateComponents.day = calendar.component(.day, from: currentDate)
            dateComponents.month = calendar.component(.month, from: currentDate)
            dateComponents.year = calendar.component(.year, from: currentDate)
            
            print(dateComponents.date as Any)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            //Scheduling notifcation for current date
            //try await triggerNotification(for: dateComponents, notificationId: UUID().uuidString)
            let center = UNUserNotificationCenter.current()
            
            await print("Pending request - \(center.pendingNotificationRequests().count)")
            
            try await UNUserNotificationCenter.current().add(request)
            
            //Incrementing the current date to one day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            print("Current date - \(currentDate)")
        }
    }
    
    ///Schedule notification for weekly and return Array of WeekDays
    private func scheduleNotificationWeekday() {
        //[Mon, tue, wed, etc..,]
        let weekDaySymbols = calendar.weekdaySymbols
        let content = getContent()
        
        for weekDay in savedWeekDays {
            var dateComponents = getNotificationDateComponents()
            // let notificationId = UUID().uuidString
            
            //Index starts from 0...
            let day = weekDaySymbols.firstIndex(where: { day in
                weekDay == day
            }) ?? -1
            
            print(day)
            
            if day != -1 {
                //Week day starts from 1-7, so adding 1 to day (index)
                dateComponents.weekday = day + 1
                
                // try await triggerNotification(for: dateComponents, notificationId: notificationId)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
                print("Weekday - \(weekDay)")
            }
        }
    }
    
    ///Scheduling notification for weekly with end date.
    private func scheduleNotificationWeeklyWithEndDate() {
        var currentDate = startDate
        let content = getContent()
        
        print("Start Date - \(startDate)")
        print("End Date - \(endDate)")
        print(currentDate)
        
        //        let formattedCurrentDate = currentDate.getDay(format: "yyyy-MM-dd")
        //        let formattedEndDate = endDate.getDay(format: "yyyy-MM-dd")
        
        while currentDate <= endDate {
            let weekSymbol = currentDate.getDay(format: "EEEE")
            print(weekSymbol)
            var dateComponents = getNotificationDateComponents()
            
            let weekDay = savedWeekDays.first { $0 == weekSymbol }
            print("Get WeekDay - \(weekDay ?? "")")
            
            if let weekDay = weekDay {
                let weekDaySymbols = calendar.weekdaySymbols
                let day = weekDaySymbols.firstIndex {  $0 == weekDay } ?? -1
                
                if day != -1 {
                    dateComponents.weekday = day + 1
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request)
                    print("Weekday number - \(day)")
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            print("currentDate - \(currentDate)")
            
            //            if weekdayw.count != 0 {
            //                let weekDaySymbols = calendar.weekdaySymbols
            //                let day = weekDaySymbols.firstIndex {  $0 == weekdayw.first } ?? -1
            //
            //                if day != -1 {
            //                    dateComponents.weekday = day + 1
            //
            //                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            //
            //                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            //
            //                    UNUserNotificationCenter.current().add(request)
            //                    print("Weekday - \(day)")
            //
            //                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            //                    print("currentDate - \(currentDate)")
            //                }
            //            }
        }
    }
    
    //    private func scheduleNotificationWeekday() async throws -> [WeekDayEntity] {
    //        var weekDayEntities = [WeekDayEntity]()
    //
    //        //[Mon, tue, wed, etc..,]
    //        let weekDaySymbols = calendar.weekdaySymbols
    //
    //        for weekDay in savedWeekDays {
    //            var dateComponents = getNotificationDateComponents()
    //            let notificationId = UUID().uuidString
    //
    //            let weekdayEntity = WeekDayEntity(context: self.context)
    //            weekdayEntity.day = weekDay
    //            weekdayEntity.notificationID = notificationId
    //            weekdayEntity.habit = self.habit
    //
    //            print(weekdayEntity)
    //
    //            //Index starts from 0...
    //            let day = weekDaySymbols.firstIndex(where: { day in
    //                weekDay == day
    //            }) ?? -1
    //
    //            print(day)
    //
    //            //Week day starts from 1-7, so adding 1 to day (index)
    //            dateComponents.weekday = day + 1
    //
    //            try await triggerNotification(for: dateComponents, notificationId: notificationId)
    //
    //            weekDayEntities.append(weekdayEntity)
    //        }
    //
    //        return weekDayEntities
    //    }
}


//
//#Preview {
//    NavigationStack {
//        let preview = PersistenceController.shared
//        AddNewHabitView(addVm: .init(context: preview))
//            .environment(\.managedObjectContext, preview.viewContext)
//    }
//}
