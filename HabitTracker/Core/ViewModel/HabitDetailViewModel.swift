//
//  HabitDetailViewModel.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI
import Observation
import CoreData

@Observable
class HabitDetailViewModel {
    var goalType: GoalUnitType
    var value: String
    var habitRecord: HabitRecord?
    private var habit: HabitEntity
    private let context: NSManagedObjectContext
    //private var habit: HabitEntity
    
    init(context: PersistenceController, selectedDate: Date, habit: HabitEntity) {
        self.context = context.viewContext
        //self.habit = HabitEntity(context: self.context)
        self.habit = habit
        self.goalType = GoalUnitType(rawValue: habit.goalPeriod ?? "") ?? .count
        self.value = habit.goal ?? ""
        self.getHabitRecord(with: selectedDate, for: habit)
    }
    
    private func getHabitRecord(with date: Date, for habit: HabitEntity) {
        //If it is false then
        if !doesHabitRecordExistForSelectedDate(habit: habit, selectedDate: date) {
            print("DEBUG: No habit record found for this habit with selected date")
            let hasDefaultDataLoaded = preloadHabitDataIfNeeded(habit: habit, selectedDate: date)
            if hasDefaultDataLoaded {
                //Fetch habit record
                loadHabitRecord(habit: habit, date: date)
                
                print("Fetch habit record")
            }
        } else {
            print("DEBUG: Habit record existed for this habit and date")
            loadHabitRecord(habit: habit, date: date)
        }
    }
    
    private func loadHabitRecord(habit: HabitEntity, date: Date) {
        guard let habitData = fetchHabitRecord(habit: habit, selectedDate: date) else { return }
        self.habitRecord = habitData
    }
    
    private func fetchHabitRecord(habit: HabitEntity, selectedDate: Date) -> HabitRecord? {
        let request = HabitRecord.getHabitRecordForDate(date: selectedDate, habit: habit)
        do {
            let results = try context.fetch(request)
            if let record = results.first {
                return record
            } else {
                return nil
            }
        } catch {
            print("ERROR: \(error)")
            return nil
        }
    }
    
    private func doesHabitRecordExistForSelectedDate(habit: HabitEntity, selectedDate: Date) -> Bool {
        let request = HabitRecord.getHabitRecordForDate(date: selectedDate, habit: habit)
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("\(error)")
        }
        
        return false
    }
    
    private func preloadHabitDataIfNeeded(habit: HabitEntity, selectedDate: Date) -> Bool {
        let habitRecord = HabitRecord(context: self.context)
        habitRecord.date = selectedDate
        habitRecord.habit = habit
        habitRecord.progress = "0"
        
        do {
            if context.hasChanges {
                try context.save()
                print("DEBUG: Habit record added successfully")
                return true
            }
        } catch {
            print("ERROR: \(error.localizedDescription)")
            return false
        }
        
        return false
    }
    
}
