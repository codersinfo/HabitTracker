//
//  ProgressRing.swift
//  HabitTracker
//
//  Created by Priya Shankar on 13/10/23.
//

import SwiftUI

struct ProgressRing<Content:View>: View {
    @Binding var progress: Double
    var primaryColor: Color
    var secondaryColor: Color
    var content: () -> Content
    
    init(progress: Binding<Double>, primaryColor: Color = .blue,
         secondaryColor: Color = .gray.opacity(0.1), @ViewBuilder content: @escaping () -> Content) {
        self._progress = progress
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .fill(secondaryColor)
                .frame(width: 300, height: 300)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .fill(primaryColor)
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(-90))
            
            content()
        }
        .padding()
    }
}

#Preview {
    ProgressRing(progress: .constant(0.5)) {
        Text("text")
            .font(.largeTitle)
            .bold()
    }
}
