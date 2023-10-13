//
//  PomodoroTimer.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI
import Observation

struct PomodoroTimer: View {
    let (minutes, second) = (25, 0)
    
    @State private var progress: CGFloat = 1
    @State private var timerValue: String = "00:00"
    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning: Bool = false
    @State private var totalSeconds: Int = 0
    @State private var remainingTotalSeconds: Int = 0
    @State private var isFinished: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.2)
                    .frame(width: 300, height: 300)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(lineWidth: 20)
                    .fill(Color.red)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(-90))
                
                Text(timerValue)
                    .font(.largeTitle)
                    .bold()
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if isTimerRunning {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }
                }, label: {
                    Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(.circle)
                })
            }
            .padding()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
            if isTimerRunning {
                updateTimer()
            }
        })
    }
    
    func formattedTime() -> String {
        let time = String(format: "%02i:%02i:%02i", hours, mins, seconds)
        return time
    }
    
    func startTimer() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isTimerRunning = true
        }
        
        hours = 1
        timerValue = hours > 0 ? String(format: "%02i:%02i:%02i", hours, mins, seconds) : String(format: "%02i:%02i", mins, seconds)
        //Total seconds for timer Animation
        totalSeconds = (hours * 3600) + (mins * 60) + seconds
        remainingTotalSeconds = totalSeconds
    }
    
    func stopTimer() {
        withAnimation(.easeInOut) {
            isTimerRunning = false
            hours = 0
            mins = 0
            seconds = 0
            progress = 1
        }
        remainingTotalSeconds = 0
        totalSeconds = 0
        timerValue = "00:00:00"
    }
    
    func updateTimer() {
        if remainingTotalSeconds > 0 {
            remainingTotalSeconds -= 1
            progress = CGFloat(remainingTotalSeconds) / CGFloat(totalSeconds)
            progress = (progress < 0 ? 0 : progress)
            hours = remainingTotalSeconds / 3600
            mins = (remainingTotalSeconds / 60) % 60
            seconds = remainingTotalSeconds % 60
            timerValue = hours > 0 ? String(format: "%02i:%02i:%02i", hours, mins, seconds) : String(format: "%02i:%02i", mins, seconds)
            
            if hours == 0 && mins == 0 && seconds == 0 {
                isTimerRunning = false
                print("Finished")
                isFinished = true
            }
        }
    }
}

#Preview {
    PomodoroTimer()
}
