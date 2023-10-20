//
//  RemainderView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 04/10/23.
//

import SwiftUI

struct RemainderView: View {
    @Bindable var addvm: AddNewHabitViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $addvm.remainderOn) {
                Text("Remainder On")
                    .bold()
            }
            
            if addvm.remainderOn {
                HStack(alignment: .center) {
                    Text(.now, style: .time)
                        .padding()
                        .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                    
                    TextField("Remainder Text", text: $addvm.remainderText)
                        .padding()
                        .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                }
                .animation(.easeIn, value: addvm.remainderOn)
            }
            
            Divider()
        }
    }
}

#Preview {
    RemainderView(addvm: .init(provider: .shared))
}
