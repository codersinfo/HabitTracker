//
//  Route.swift
//  HabitTracker
//
//  Created by Priya Shankar on 17/10/23.
//

import Foundation
import SwiftUI

enum Route: Hashable, View {
    case detail(HabitEntity, Date, PersistenceController, HabitRecord?)
    //    case list
    //    case add
    
    var body: some View {
        switch self {
        case .detail(let habit, let date, let provider, let record):
            HabitDetailView(habit: habit, selectedDate: date, context: provider, habitRecord: record)
        }
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}
