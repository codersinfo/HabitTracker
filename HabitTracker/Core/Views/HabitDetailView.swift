//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 12/10/23.
//

import SwiftUI

struct HabitDetailView: View {
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.2)
                
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(lineWidth: 20)
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding()
    }
}


#Preview {
    HabitDetailView()
}
