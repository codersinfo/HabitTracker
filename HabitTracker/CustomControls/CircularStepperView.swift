//
//  CircularStepperView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 13/10/23.
//

import SwiftUI

struct CircularStepperView: View {
    @State var progress: Double = 0.2
    
    var body: some View {
        VStack {
            ProgressRing(progress: $progress, primaryColor: .pink) {
                Text("1")
            }
        }
    }
}

#Preview {
    CircularStepperView()
}
