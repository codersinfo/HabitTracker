//
//  HabitListView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 03/10/23.
//

import SwiftUI

struct HabitListView: View {
    @State var showAddNewHabitView: Bool = false
    @FetchRequest(fetchRequest: HabitEntity.all()) private var habits
    
    var provider = PersistenceController.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(habits) { habit in
                    VStack {
                        Text("\(habit.id)")
                        HStack {
                            Text(habit.name)
                            Spacer()
                            Capsule()
                                .fill(Color(habit.color))
                                .frame(width: 70, height: 50)
                        }
                        
//                        HStack {
//                            ForEach(habit.weekdayArray) { weekDay in
//                                Text(weekDay.day ?? "")
//                            }
//                        }
                        
                        WeekView(habit: habit)
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddNewHabitView.toggle()
                    }, label: {
                        Text("Add")
                    })
                }
            })
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    print(habits)
//                }
//            }
            .sheet(isPresented: $showAddNewHabitView, content: {
                NavigationStack {
                    AddNewHabitView(addVm: .init(context: provider))
                }
            })
        }
    }
}

#Preview {
    HabitListView()
}


struct WeekView: View {
    @FetchRequest(sortDescriptors: []) private var weekDays: FetchedResults<WeekDayEntity>
    
    init(habit: HabitEntity) {
        _weekDays = FetchRequest(fetchRequest: WeekDayEntity.all(myhabit: habit))
    }
    
    var body: some View {
        HStack {
            ForEach(weekDays) { weekDay in
                VStack {
                    Text(weekDay.day ?? "")
                }
            }
        }
    }
}
