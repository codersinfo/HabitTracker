//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI

struct HabitDetailView: View {
    private var goalType: GoalUnitType
    private var value: String
    
    init(goalType: GoalUnitType = .count, value: String) {
        self.goalType = goalType
        self.value = value
    }
    
    var body: some View {
        VStack {
            ZStack {
                switch goalType {
                case .hoursMins:
                    if let gethoursAndTime = getTime(for: value) {
                        PomodoroTimerView(timing: .init(hours: Int(gethoursAndTime[0]) ?? 0, mins: Int(gethoursAndTime[1]) ?? 0))
                    }
                default:
                    CircularStepperView(totalCount: Int(value) ?? 0)
                }
            }
        }
        .padding()
    }
    
    private func getTime(for value: String) -> [String]? {
        if !value.isEmpty {
            let splitedValue = value.components(separatedBy: ":")
            print("\(splitedValue)")
            return splitedValue
        }
        
        return nil
    }
}


#Preview {
    HabitDetailView(goalType: .hoursMins, value: "00:02")
}


//extension HabitDetailView {
//
//}
