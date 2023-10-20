//
//  HabitsView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 06/10/23.
//

import SwiftUI
import CoreData



struct FilteredHabitsView: View {
    @FetchRequest private var request: FetchedResults<HabitEntity>
    private var provider: PersistenceController
    private let selectedDate: Date
    
    init(dateToFilter: Date, providerContext: PersistenceController) {
        // _request = FetchRequest(fetchRequest: HabitEntity.all())
        // _request = FetchRequest(fetchRequest: HabitEntity.getFilteredData(for: dateToFilter))
        // _request = FetchRequest(fetchRequest: HabitEntity.getFilteredDataForWeekly(for: dateToFilter))
        //print(request)
        self.selectedDate = dateToFilter
        provider = providerContext
        _request = FetchRequest(fetchRequest: HabitEntity.getHabitDate(for: dateToFilter))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(request) { habit in
                    NavigationLink(value: Route.detail(habit, selectedDate, provider, fetchHabitRecord(habit: habit, selectedDate: selectedDate))) {
                        VStack {
                            RoundedRectProgressBar(text: habit.name, color: Color(habit.color), progress: getProgressValue(habit: habit))
                                .frame(height: 60)
                            HStack {
                                ForEach(habit.weekdayArray) { day in
                                    Text(day.day ?? "")
                                }
                            }
                            
                            Text("\(getProgressValue(habit: habit))")
                            if let habitRecordForSelecredDate = fetchHabitRecord(habit: habit, selectedDate: selectedDate) {
                                Text(habitRecordForSelecredDate.progress ?? "")
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            //            print(Date.yesterday)
            //            print(Date.tomorrow)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                print(request)
//            }
        })
    }
    
    func getProgressValue(habit: HabitEntity) -> CGFloat {
        guard let record = fetchHabitRecord(habit: habit, selectedDate: selectedDate) else { return 0 }
        
        if habit.goalPeriod == GoalUnitType.hoursMins.rawValue {
            return 0.2
        } else {
            let totalCount = Int(habit.goal ?? "") ?? 0
            let recordCount = Int(record.progress ?? "0") ?? 0
            let progress = CGFloat(recordCount) / CGFloat(totalCount)
            return progress
        }
       // return 0
    }
    
    private func fetchHabitRecord(habit: HabitEntity, selectedDate: Date) -> HabitRecord? {
        let request = HabitRecord.getHabitRecordForDate(date: selectedDate, habit: habit)
        do {
            let results = try provider.viewContext.fetch(request)
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
}

#Preview {
    Group {
        let preview = PersistenceController.shared
        NavigationStack {
            FilteredHabitsView(dateToFilter: Date(), providerContext: preview)
                .environment(\.managedObjectContext, preview.viewContext)
                .onAppear {
                    HabitEntity.makePreview(count: 5, in: preview.viewContext)
                }
        }
    }
}
