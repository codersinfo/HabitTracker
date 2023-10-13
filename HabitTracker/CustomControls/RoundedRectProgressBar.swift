//
//  ProgressBar.swift
//  HabitTracker
//
//  Created by Priya Shankar on 06/10/23.
//

import SwiftUI

struct RoundedRectProgressBar: View {
    var text: String = "Habit name"
    @Binding var value: Float
    var color: Color = .green
    
    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .frame(width: geo.size.width, height: geo.size.height)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: geo.size.width * CGFloat(value), height: geo.size.height)
                .animation(.linear, value: value)
            
            HStack {
                Text(text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                Image(systemName: "checkmark")
            }
            .padding(.horizontal)
            .frame(height: geo.size.height, alignment: .center)
        }
    }
}

#Preview {
    RoundedRectProgressBar(value: .constant(2/10))
        .frame(height: 60)
        .padding()
}
