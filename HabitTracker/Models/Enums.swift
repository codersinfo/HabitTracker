//
//  Enums.swift
//  HabitTracker
//
//  Created by Priya Shankar on 03/10/23.
//

import Foundation

enum GoalUnitType: String, CaseIterable {
    case meter, kiloMeter, hoursMins, count
    
    var name: String {
        switch self {
        case .hoursMins:
            "Hour & mins"
        default:
            rawValue.capitalized
        }
    }
}


//enum Frequency: String, CaseIterable, Identifiable {
//    case daily
//    case weekly
//    case monthly
//    
//    var id: String {
//        UUID().uuidString
//    }
//
//    var name: String {
//        rawValue.capitalized
//    }
//}
//
//enum HabitType: String, CaseIterable, Identifiable {
//    case build
//    case quit
//
//    var id: String {
//        UUID().uuidString
//    }
//
//    var name: String {
//        rawValue.capitalized
//    }
//}
//
//enum TimeRange: String, CaseIterable, Identifiable {
//    case anytime
//    case morning
//    case afternoon
//    case evening
//
//    var id: String {
//        UUID().uuidString
//    }
//
//    var name: String {
//        rawValue.capitalized
//    }
//}
