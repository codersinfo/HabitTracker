//
//  Date+Extension.swift
//  HabitTracker
//
//  Created by Priya Shankar on 09/10/23.
//

import Foundation


extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow: Date { return Date().dayAfter }
    
    var dayBefore: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var dayAfter: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func getDate(number: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: number, to: self)!
    }
    
//    func dateForWeekNumber(_ weekday: Int) -> Date {
//        var dateComponents = DateComponents()
//        dateComponents.weekday = weekday
//        dateComponents.hour = 0
//        dateComponents.minute = 0
//        let calendar = Calendar.current
//                let today = Date()
//
//        // Find the next occurrence of the selected weekday from today's date
//        if let nextDate = calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTime) {
//            return nextDate
//        } else {
//            // If the selected weekday is today, return today's date
//            return today
//        }
//    }
    
//    func dateForWeekday(_ weekday: Int) -> Date {
//           let calendar = Calendar.current
//           let today = Date()
//           let todayWeekday = calendar.component(.weekday, from: today)
//           let daysToAdd = (weekday - todayWeekday + 7) % 7 // Calculate the number of days to add to reach the desired weekday
//
//           return calendar.date(byAdding: .day, value: daysToAdd, to: today)!
//       }
    
    func dateForWeekday(_ weekday: Int) -> Date {
        let calendar = Calendar.current
                  let today = Date()
        
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        dateComponents.weekday = weekday
        return calendar.date(from: dateComponents)!
    }
}
