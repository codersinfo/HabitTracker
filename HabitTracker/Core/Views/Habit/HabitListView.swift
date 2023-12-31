//
//  HabitListView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 03/10/23.
//

import SwiftUI

struct HabitListView: View {
    @State var showAddNewHabitView: Bool = false
    // @FetchRequest(fetchRequest: HabitEntity.all()) private var habits
    @State var listVm = HabitListViewModel()
    @Namespace var weeklyViewNameSpace
    
    var provider = PersistenceController.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                //MARK: Weekly calendar view
                HStack {
                    ForEach(listVm.currentWeek, id:\.self) { day in
                        VStack(spacing: 12) {
                            Text(day.getDay(format: "EE"))
                            Text(day.getDay(format: "d"))
                        }
                        .foregroundStyle(listVm.isToday(date: day) ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if listVm.isToday(date: day) {
                                    Capsule()
                                        .fill(Color.indigo)
                                        .matchedGeometryEffect(id: "week", in: weeklyViewNameSpace)
                                }
                            }
                        )
                        .onTapGesture {
                            withAnimation {
                                listVm.currentDate = day
                            }
                        }
                    }
                }
                
                FilteredHabitsView(dateToFilter: listVm.currentDate, providerContext: provider)
            }
            .navigationDestination(for: Route.self, destination: { $0 })
            .sheet(isPresented: $showAddNewHabitView, content: {
                NavigationStack {
                    AddNewHabitView(addVm: .init(provider: provider))
                }
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddNewHabitView.toggle()
                    }, label: {
                        Text("Add")
                    })
                }
            })
            .padding()
            .navigationTitle("Habits")
        }
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


struct WeekView: View {
    @FetchRequest private var weekDays: FetchedResults<WeekDayEntity>
    
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
