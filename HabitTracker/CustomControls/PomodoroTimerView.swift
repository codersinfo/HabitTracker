//
//  PomodoroTimerView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI
import UserNotifications

//enum TimerMode {
//    case running
//    case paused
//    case initial
//}

struct Timing {
    var totalTimeInMinutes: Int
    var totalTimeInHours: Int
    var totalTimeInSeconds: Int
    
    init(hours totalTimeInHours: Int, mins totalTimeInMinutes: Int, seconds: Int) {
        self.totalTimeInHours = 0
        self.totalTimeInMinutes = 0
        self.totalTimeInSeconds = (totalTimeInHours * 3600 + totalTimeInMinutes * 60) + seconds
    }
}

struct PomodoroTimerView: View {
    var totalTiming: Timing
    var recordTiming: Timing
    @State private var remainingTimeInSeconds: Int = 0
    @State private var timer: Timer?
    @State private var timeString: String = "00:00:00"
    @State private var completionString: String = "00:00:00"
    @State private var isTimerRunning: Bool = false
    @State var progress: Double = 1
    private var notificationIdentifier: String = UUID().uuidString
    var completion: (String, String?) -> Void
    
//    init(timing: Timing, progress: Binding<Double>, completion: @escaping (String, String?) -> Void) {
//        self.timing = timing
//        self._progress = progress
//        self.completion = completion
//    }
    
    init(totalTiming: Timing, recordTiming: Timing, completion: @escaping (String, String?) -> Void) {
        self.totalTiming = totalTiming
        self.recordTiming = recordTiming
        //self._progress = progress
        self.completion = completion
   }
    
    var body: some View {
        VStack {
            ProgressRing(progress: $progress, primaryColor: .mint) {
                Text(timeString)
                    .font(.largeTitle)
                    .bold()
            }
            .padding(.bottom, 40)
            
            HStack(spacing: 12) {
                Spacer()
                
                Button {
                    if isTimerRunning {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                } label: {
                    HStack {
                        Label(isTimerRunning ? "Pause" : "Start", systemImage: isTimerRunning ?  "pause" : "play")
                            .font(.title3)
                            .foregroundStyle(.mint)
                            .padding(12)
                            .frame(width: 120)
                            .background {
                                Capsule()
                                    .stroke(lineWidth: 2)
                                    .fill(Color.mint)
                            }
                    }
                }
                
                Button {
                    resetTimer()
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                } label: {
                    HStack {
                        Label("Reset", systemImage: "arrow.clockwise")
                            .font(.title3)
                            .foregroundStyle(.mint)
                            .padding(12)
                            .frame(width: 120)
                            .background {
                                Capsule()
                                    .stroke(lineWidth: 2)
                                    .fill(Color.mint)
                            }
                    }
                }
                
                Spacer()
            }
        }
        .onChange(of: remainingTimeInSeconds, {
            completion(completionString, nil)
        })
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                progress = CGFloat(recordTiming.totalTimeInSeconds) / CGFloat(totalTiming.totalTimeInSeconds)
            }
            defaultTimer()
        }
        .onDisappear(perform: {
            print("OnDisapper just hit")
            isTimerRunning = false
            timer?.invalidate()
            timer = nil
        })
    }
    
    private func defaultTimer() {
        remainingTimeInSeconds = recordTiming.totalTimeInSeconds
        formattedTime()
    }
    
    private func startTimer() {
        withAnimation(.easeOut(duration: 0.25)) {
            isTimerRunning = true
            timer = nil
            scheduleNotification()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                if remainingTimeInSeconds > 0 {
                    remainingTimeInSeconds -= 1
                    progress = CGFloat(remainingTimeInSeconds) / CGFloat(totalTiming.totalTimeInSeconds)
                    print(progress)
                    formattedTime()
                } else if remainingTimeInSeconds == 0 {
                    completion(completionString, "Finished")
                    isTimerRunning = false
                    timer?.invalidate()
                    timer = nil
                } else {
                    resetTimer()
                }
            })
        }
    }
    
    private func pauseTimer() {
        completion(completionString, "Paused")
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isTimerRunning = false
            timer?.invalidate()
            timer = nil
            progress = 1.0
            //defaultTimer()
            remainingTimeInSeconds = totalTiming.totalTimeInSeconds
            formattedTime()
            completion(completionString, "Reset")
        }
    }
    
    ///Formatting Time to display hrs : mins : seconds
    private func formattedTime() {
        let hrs = remainingTimeInSeconds / 3600
        let mins = (remainingTimeInSeconds / 60) % 60
        let seconds = remainingTimeInSeconds % 60
        // print(String(format: "%02i:%02i:%02i", hrs, mins, seconds))
        timeString = hrs > 0 ? String(format: "%02i:%02i:%02i", hrs, mins, seconds) : String(format: "%02i:%02i", mins, seconds)
        completionString = String(format: "%02i:%02i:%02i", hrs, mins, seconds)
        //  print(timeString)
    }
    
    //MARK: Schedule notification
    ///Schedule notification when the timer is finished
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time is up"
        content.subtitle = "Completed"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(remainingTimeInSeconds), repeats: false)
        //self.notificationIdentifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    PomodoroTimerView(totalTiming: .init(hours: 0, mins: 1, seconds: 0), recordTiming: .init(hours: 0, mins: 0, seconds: 55)) { newValue, state in
        print("\(newValue), \(String(describing: state))")
    }
    // PomodoroTimerView(timing: .init(hours: 1, mins: 30), progress: .constant(0), completion: () -> (String))
}

//            ZStack {
//                Circle()
//                    .stroke(lineWidth: 30)
//                    .fill(Color.gray.opacity(0.1))
//                    .frame(width: 300, height: 300)
//
//                Circle()
//                    .trim(from: 0, to: progress)
//                    .stroke(lineWidth: 10)
//                    .fill(Color.mint)
//                    .frame(width: 340, height: 340)
//                    .rotationEffect(.degrees(-90))
//
//                Text(timeString)
//                    .font(.largeTitle)
//                    .bold()
//            }
//            .padding()

//    func formattedTimeToDisplay() {
//        let hrs = remainingTime / 3600
//        let minsLeft = remainingTime - hrs*3600
//        let mins = minsLeft / 60
//        let seconds = remainingTime - mins*60
//        if hrs > 0 {
//            timeString = String(format: "%02i:%02i:%02i", hrs, mins, seconds)
//        } else {
//            timeString = String(format: "%02i:%02i", mins, seconds)
//        }
//    }

//    func startTimer() {
//        timer = nil
//        isTimerRunning = true
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if remainingTime > 0 {
//                remainingTime -= 1
//                progress = CGFloat(remainingTime) / CGFloat(timing.totalTimeInSeconds)
//            }
//        }
//    }
//
//    func resetTimer() {
//        isTimerRunning = false
//        timer?.invalidate()
//        timer = nil
//        formattedTimeToDisplay()
//        progress = 1.0
//        remainingTime = 0
//    }
