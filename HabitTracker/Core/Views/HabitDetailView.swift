//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI
import CoreData

struct HabitDetailView: View {
//    private var goalType: GoalUnitType
//    private var value: String
    
//    init(goalType: GoalUnitType = .count, value: String) {
//        self.goalType = goalType
//        self.value = value
//    }
    
//    private let context: NSManagedObjectContext
//    private var habit: HabitEntity
    //var provider: PersistenceController
    @State var habitRecordVm: HabitDetailViewModel
    
    init(habit: HabitEntity, selectedDate: Date, context: PersistenceController) {
//        self.context = context.viewContext
//        self.habit = HabitEntity(context: self.context)
        _habitRecordVm = .init(initialValue: HabitDetailViewModel(context: context, selectedDate: selectedDate, habit: habit))
    }

    var body: some View {
        VStack {
            Text(habitRecordVm.habitRecord?.progress ?? "Progress unknown")
            ZStack {
                switch habitRecordVm.goalType {
                case .hoursMins:
                    if let gethoursAndTime = getTime(for: habitRecordVm.value) {
                        PomodoroTimerView(timing: .init(hours: Int(gethoursAndTime[0]) ?? 0, mins: Int(gethoursAndTime[1]) ?? 0))
                    }
                default:
                    CircularStepperView(totalCount: Int(habitRecordVm.value) ?? 0)
                }
            }
        }
        .padding()
    }
    
    private func getTime(for value: String) -> [String]? {
        if !value.isEmpty {
            let splitedValue = value.components(separatedBy: ":")
            print("\(splitedValue)")
            return splitedValue
        }
        
        return nil
    }
}


#Preview {
    Group {
        let preview = PersistenceController.shared
        HabitDetailView(habit: .preview(context: preview.viewContext), selectedDate: .now, context: preview)
    }
   // HabitDetailView(goalType: .hoursMins, value: "00:02")
    
}
