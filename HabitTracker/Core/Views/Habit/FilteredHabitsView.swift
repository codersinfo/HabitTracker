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
    var provider: PersistenceController
    let selectedDate: Date
    
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
                    //                    Route.detail(goalPeriod ?? .count, habit.goal ?? "")
                    //                    let goalPeriod = GoalUnitType(rawValue: habit.goalPeriod ?? "")
                    NavigationLink(value: Route.detail(habit, selectedDate, provider)) {
                        VStack {
                            RoundedRectProgressBar(text: habit.name, value: .constant(0.4), color: Color(habit.color))
                                .frame(height: 60)
                            
                            HStack {
                                ForEach(habit.weekdayArray) { day in
                                    Text(day.day ?? "")
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            //            print(Date.yesterday)
            //            print(Date.tomorrow)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print(request)
            }
        })
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
