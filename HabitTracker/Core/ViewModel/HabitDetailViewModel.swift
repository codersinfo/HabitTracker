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
    var goalCount: String = ""
    var recordCount: String = ""
    
    var habitRecord: HabitRecord?
    var totalRecordingTiming: Timing?
    var habitRecordtiming: Timing?
    
    var habit: HabitEntity
    private let context: NSManagedObjectContext
    private var selectedDate: Date
    //private var habit: HabitEntity
    
    init(provider: PersistenceController, selectedDate: Date, habit: HabitEntity, habitRecord: HabitRecord? = nil) {
        self.context = provider.viewContext
        self.selectedDate = selectedDate
        self.goalType = GoalUnitType(rawValue: habit.goalPeriod ?? "") ?? .count
        self.habit = habit
        
        if let habitRecord, let existingHabitRecord = try? self.context.existingObject(with: habitRecord.objectID) as? HabitRecord {
            self.habitRecord = existingHabitRecord
        } else {
            //Creating new habit record.
            self.habitRecord = HabitRecord(context: context)
            self.getHabitRecord(with: self.selectedDate, for: self.habit)
        }
        
//        if let existingHabit = try? self.context.existingObject(with: habit.objectID) as? HabitEntity {
//            self.habit = existingHabit
//            print("Habit existed")
//            if let habitData = fetchHabitRecord(habit: self.habit, selectedDate: self.selectedDate) {
//                if let existingHabitRecord = try? self.context.existingObject(with: habitData.objectID) as? HabitRecord {
//                    print("Habit existed record")
//                    self.habitRecord = existingHabitRecord
//                } else {
//                    self.habitRecord = HabitRecord(context: context)
//                }
//            } else {
//                self.habitRecord = HabitRecord(context: context)
//            }
//        } else {
//            self.habit = habit
//        }
        
        
        getProgress()
    }
    
    func getProgress() {
        if goalType == .hoursMins {
            self.totalRecordingTiming = getDuration(value: habit.goal ?? "")
            self.habitRecordtiming = getDuration(value: habitRecord?.progress ?? "") //?? .init(hours: 0, mins: 0, seconds: 0)
            //self.progress = CGFloat(habitRecordtiming?.totalTimeInSeconds ?? 0) / CGFloat(habitOriginalDuration?.totalTimeInSeconds ?? 0)
        } else {
            //print("progress state = \(progress)")
            self.goalCount = habit.goal ?? ""
            self.recordCount = habitRecord?.progress ?? ""
            // self.progress = 0.0001
        }
    }
    
    func delete() throws {
        let existingHabit = try context.existingObject(with: habitRecord!.objectID)
        context.delete(existingHabit)
        try save()
        print("Deleted Successfully")
    }
    
    //    func updateHabitRecord(progress: String, isFinished: Bool) {
    //        if let existingHabit = try? self.context.existingObject(with: habitRecord!.objectID) {
    //            self.habitRecord = existingHabit as? HabitRecord
    //            //self.habit = habit
    //            if isFinished {
    //                habitRecord?.isCompleted = true
    //            }
    //
    //            if !progress.isEmpty {
    //                habitRecord?.progress = progress
    //            }
    //
    //            do {
    //                try save()
    //                print("Updated Successfully")
    //                loadHabitRecord(habit: self.habit, date: self.selectedDate)
    //                //  self.habitRecordtiming = getDuration(value: self.value)
    //            } catch {
    //                print("ERROR: \(error)")
    //            }
    //        }
    //    }
    
    func deleteHabit() throws {
        let existingHabit = try context.existingObject(with: habit.objectID)
        context.delete(existingHabit)
        try save()
        print("Deleted Successfully")
    }
    
//    func update() throws {
//        //let existingHabit = try context.existingObject(with: habit.objectID) as? HabitRecord
//       // existingHabit?.progress = "332"
//        habitRecord?.progress = "332"
//        habit.habitRecords?.adding(habitRecord!)
//        //habit.habitRecords?.adding(existingHabit!)
//        try context.save()
//    }
    
    func getDuration(value: String) -> Timing? {
        if let gethoursAndTime = getSplitedTime(for: value) {
            return Timing(hours: Int(gethoursAndTime[0]) ?? 0, mins: Int(gethoursAndTime[1]) ?? 0, seconds: Int(gethoursAndTime[2]) ?? 0)
        }
        return nil
    }
    
    private func getSplitedTime(for value: String) -> [String]? {
        if !value.isEmpty {
            let splitedValue = value.components(separatedBy: ":")
            print("\(splitedValue)")
            return splitedValue
        }
        
        return nil
    }
}

extension HabitDetailViewModel {
    private func getHabitRecord(with date: Date, for habit: HabitEntity) {
        //If it is false then
        if !doesHabitRecordExistForSelectedDate(habit: habit, selectedDate: date) {
            print("DEBUG: No habit record found for this habit with selected date")
            let hasDefaultDataLoaded = preloadHabitDataIfNeeded(progress: "0", isFinished: false)
            if hasDefaultDataLoaded {
                //Fetch habit record
                //loadHabitRecord(habit: habit, date: date)
                
                print("Fetch habit record")
            }
        } else {
            print("DEBUG: Habit record existed for this habit and date")
            //loadHabitRecord(habit: habit, date: date)
        }
    }
    
//    private func loadHabitRecord(habit: HabitEntity, date: Date) {
//        guard let habitData = fetchHabitRecord(habit: self.habit, selectedDate: date) else { return }
        // self.habitRecord = habitData
        
        
        //        guard let habitData = fetchHabitRecord(habit: habit, selectedDate: date) else { return }
        //        if let existingHabitRecord = try? context.existingObject(with: habitData.objectID) as? HabitRecord {
        //            self.habitRecord = existingHabitRecord
        //            if goalType == .hoursMins {
        //                // self.value = habitRecord?.progress ?? "0:0:0"
        //            } else {
        //                //self.value = habit.goal ?? "0"
        //            }
        //        }
   // }
    
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
    
    func preloadHabitDataIfNeeded(progress: String, isFinished: Bool) -> Bool {
        habitRecord?.date = selectedDate
        habitRecord?.habit = self.habit
        
        self.habit.habitRecords?.adding(habitRecord!)
        
        if goalType == .hoursMins {
            habitRecord?.progress = self.habit.goal
        } else {
            habitRecord?.progress = progress
        }
        
        do {
            try save()
            print("DEBUG: Habit record added successfully")
            return true
        } catch {
            print("ERROR: \(error.localizedDescription)")
            return false
        }
        
        // return false
    }
    
    func save() throws {
       // if context.hasChanges {
            try context.save()
       // }
    }
    
    //    func save2() throws {
    //        try context.save()
    //    }
}
