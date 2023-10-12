//
//  PomodoroTimerView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI

struct PomodoroTimerView: View {
    let totalTimeInSeconds: Int = 0
    
    @State var remainingTime: Int = 0
    @State var isTimerRunning = false
    @State var timer: Timer?
    @State var progress: Double = 1
    @State var timeString: String = ""
    var body: some View {
        ZStack {
            
        }
    }
    
    func formattedTimeToDisplay() {
        let hrs = remainingTime / 3600
        let minsLeft = remainingTime - hrs*3600
        let mins = minsLeft / 60
        let seconds = remainingTime - mins*60
        if hrs > 0 {
            timeString = String(format: "%02i:%02i:%02i", hrs, mins, seconds)
        } else {
            timeString = String(format: "%02i:%02i", mins, seconds)
        }
    }
    
    func startTimer() {
        timer = nil
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
                progress = CGFloat(remainingTime) / CGFloat(totalTimeInSeconds)
            }
        }
    }
    
    func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        formattedTimeToDisplay()
        progress = 1.0
        remainingTime = 0
    }
}

#Preview {
    PomodoroTimerView()
}
