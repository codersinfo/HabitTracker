//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI
import CoreData

struct HabitDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var isPresented: Bool = false
    @State var habitRecordVm: HabitDetailViewModel
    var context: PersistenceController
    
    init(habit: HabitEntity, selectedDate: Date, context: PersistenceController, habitRecord: HabitRecord?) {
        print("DEBUG: Habit Detail Init")
        self.context = context
        _habitRecordVm = .init(initialValue: HabitDetailViewModel(provider: context, selectedDate: selectedDate, habit: habit, habitRecord: habitRecord))
    }
    
    var body: some View {
        VStack {
            Text(habitRecordVm.habitRecord?.progress ?? "Progress unknown")
            ZStack {
                switch habitRecordVm.goalType {
                case .hoursMins:
                    hourMinsView
                default:
                    countView
                }
            }
            
            Button {
                //do {
                    //try habitRecordVm.update()
                    dismiss()
//                    print("DEBUG: On Dispear")
//                } catch {
//                    print("Error \(error)")
//                }
                
//                Task(priority: .background) {
//                    try await context.perform {
//                        try context.save()
//                        dismiss()
//                    }
//                }
            } label: {
                Text("back")
            }

        }
        .sheet(isPresented: $isPresented, content: {
            NavigationStack {
                AddNewHabitView(addVm: .init(provider: context, habit: habitRecordVm.habit))
            }
        })
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("Edit")
                    }
                    
                    Button(role: .destructive) {
                        do {
                            try habitRecordVm.deleteHabit()
                            dismiss()
                        } catch {
                            print("\(error)")
                        }
                        
                    } label: {
                        Text("Delete")
                    }

                } label: {
                    Image(systemName: "plus")
                }
            }
        })
        .padding()
    }}


#Preview {
    Group {
        let preview = PersistenceController.shared
        NavigationStack {
            HabitDetailView(habit: .previewWithCount(context: preview.viewContext), selectedDate: .now, context: preview, habitRecord: nil)
        }
    }
}

extension HabitDetailView {
    var hourMinsView: some View {
        ZStack {
            if let duration = habitRecordVm.totalRecordingTiming {
                PomodoroTimerView(totalTiming: duration, 
                                  recordTiming: habitRecordVm.habitRecordtiming!) { timeString, state in
                    print("\(timeString), \(String(describing: state))")
                    if let state {
                        print("\(state)")
                       let _ = habitRecordVm.preloadHabitDataIfNeeded(progress: timeString, isFinished: false)
                    }
                }
            }
        }
    }
    
    var countView: some View {
        ZStack {
            CircularStepperView(totalCount: Int(habitRecordVm.goalCount) ?? 0,
                                recordCount: Int(habitRecordVm.recordCount) ?? 0) { remainingCount, state in
                print("\(remainingCount), \(String(describing: state))")
                if let state {
                    print("\(state)")
                    let _ = habitRecordVm.preloadHabitDataIfNeeded(progress: String(remainingCount), isFinished: false)
                }
            }
        }
    }
}
