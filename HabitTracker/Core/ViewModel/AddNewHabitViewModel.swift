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

@Observable
class AddNewHabitViewModel {
    var name: String = ""
    var note: String = ""
    var icon: String = "book"
    var color: String = "card-1"
    var hasGoalSet: Bool = false
    var goal: String = ""
    var goalPeriod: String = ""
    var timeRange: TimeRange = .anytime
    var frequency: Frequency = .daily
    var isRepeat: Bool = false
    var savedWeekDays: [String] = ["Sunday"]
    var remainderOn: Bool = false
    var remainderText: String = ""
    var remainderDate: Date = .now
    
    var habit: HabitEntity
    var weekDays: WeekDayEntity? = nil
    
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    init(context: PersistenceController, habit: HabitEntity? = nil) {
        self.context = context.newViewContext
        self.habit = HabitEntity(context: self.context)
        self.weekDays = WeekDayEntity(context: self.context)
    }
    
    func save() async throws {
        habit.name = name
        habit.color = color
        habit.note = note
        habit.icon = icon
        habit.timeRange = timeRange.rawValue
        habit.frequency = frequency.rawValue
        habit.startDate = .now
        
        if hasGoalSet {
            if !goal.isEmpty {
                habit.goal = goal
                habit.goalPeriod = goalPeriod
            } else {
                //Show error alert
            }
        }
        
        if remainderOn {
            if !remainderText.isEmpty {
                habit.isRemainderOn = remainderOn
                habit.remainderText = remainderText
                habit.notificationTime = remainderDate
                
                if frequency == .weekly {
                    if let weekEntities = try? await scheduleNotificationWeekday() {
                        //habit.weekDays = weekDays
                        //habit.weekDays?.addingObjects(from: weekEntities)
                        habit.weekDays = Set(weekEntities) as NSSet
                    }
                } else if frequency == .monthly {
                    
                } else {
                    try await scheduleNotificationEveryDay()
                }
            }
        }
        
        print(habit)
        if context.hasChanges {
            try context.save()
        }
    }
    
    //Handle all the notifications
    @discardableResult
    private func scheduleNotificationEveryDay() async throws -> Bool {
        let dateComponents = getNotificationDateComponents()
        let id = UUID().uuidString
        
        if let _ = try? await triggerNotification(for: dateComponents, notificationId: id) {
            return true
        }
        
        return false
    }
    
    private func getNotificationDateComponents() -> DateComponents {
        //let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: remainderDate)
        dateComponents.minute = calendar.component(.minute, from: remainderDate)
        
        return dateComponents
    }
    
    func scheduleNotificationWeekday() async throws -> [WeekDayEntity] {
        var weekDayEntities = [WeekDayEntity]()
        
        let weekDaySymbols = calendar.weekdaySymbols
        
        for weekDay in savedWeekDays {
            var dateComponents = getNotificationDateComponents()
            let notificationId = UUID().uuidString
            
            let weekdayEntity = WeekDayEntity(context: self.context)
            weekdayEntity.day = weekDay
            weekdayEntity.notificationID = notificationId
            weekdayEntity.habit = habit
            
            print(weekdayEntity)
            
            //Index starts from 0...
            let day = weekDaySymbols.firstIndex(where: { day in
                weekDay == day
            }) ?? -1
            
            print(day)
            
            //Week day starts from 1-7, so adding 1 to day (index)
            dateComponents.weekday = day + 1
            
            try await triggerNotification(for: dateComponents, notificationId: notificationId)
            
            weekDayEntities.append(weekdayEntity)
        }
        
        return weekDayEntities
    }
    
    func triggerNotification(for dateComponent: DateComponents, notificationId: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = name
        content.subtitle = remainderText
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}
