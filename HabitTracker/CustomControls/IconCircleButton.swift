//
//  IconCircleButton.swift
//  HabitTracker
//
//  Created by Priya Shankar on 13/10/23.
//

import SwiftUI

struct IconCircleButton: View {
    let icon: String
    var iconColor: Color = .blue
    var bgColor: Color = .gray
    var action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(iconColor)
                .padding()
                .frame(width: 60, height: 60)
                .background(bgColor)
                .clipShape(.circle)
        })
    }
}

#Preview {
    IconCircleButton(icon: "scribble.variable") {
        
    }
}
