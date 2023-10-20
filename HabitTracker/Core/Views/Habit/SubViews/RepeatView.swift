//
//  RepeatView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 04/10/23.
//

import SwiftUI

struct RepeatView: View {
    @Bindable var addvm: AddNewHabitViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $addvm.isRepeat) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Repeat")
                        .bold()
                    
                    Text("Never")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
            
            if addvm.isRepeat {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Frequency")
                        .bold()
                    
                    FrequencyView(addvm: addvm)
                }
                .animation(.easeInOut, value: addvm.isRepeat)
            }
            Divider()
        }
    }
}

#Preview {
    RepeatView(addvm: .init(provider: .shared))
}
