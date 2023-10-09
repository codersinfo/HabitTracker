//
//  HabitListViewModel.swift
//  HabitTracker
//
//  Created by Priya Shankar on 06/10/23.
//

import Foundation


@Observable
final class HabitListViewModel {
    var currentWeek: [Date] = []
    var currentDate: Date = Date()
    
    init() {
        getCurrentWeek()
    }
    
    func getCurrentWeek() {
        var calendar = Calendar.current
        //Week day starts with 1 - sunday ...
        calendar.firstWeekday = 1
        let today = calendar.startOfDay(for: Date())
        
        if let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today) {
            for i in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                    currentWeek.append(day)
                }
            }
        }
        
//        let currentWeek = calendar.component(.weekOfYear, from: currentDate) - current week number
       // print(currentWeek)
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDate, inSameDayAs: date)
    }
}

extension Date {
    func getDay(format: String) -> String {
        let dateFormattter = DateFormatter()
        dateFormattter.dateFormat = format
        
        return dateFormattter.string(from: self)
    }
}
