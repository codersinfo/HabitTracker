//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Priya Shankar on 28/09/23.
//

import SwiftUI

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            HabitListView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .onAppear(perform: {
                    NotificationManager.instance.requestAuthorization()
                })
            
            //            PomodoroTimerView(timing: <#Timing#>)
            //                .onAppear(perform: {
            //                    NotificationManager.instance.requestAuthorization()
            //                })
        }
    }
}
