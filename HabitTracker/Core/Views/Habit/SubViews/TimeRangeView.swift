//
//  TimeRangeView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 04/10/23.
//

import SwiftUI

enum TimeRange: String, Identifiable, CaseIterable {
    case anytime, morning, afternoon, evening
    
    var id: String {
        rawValue
    }
}

struct TimeRangeView: View {
    @Bindable var addvm: AddNewHabitViewModel
    
    let gridItems: [GridItem] = [GridItem(.flexible(), spacing: 14), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Time range")
                .bold()
            LazyVGrid(columns: gridItems, spacing: 14) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.rawValue.capitalized)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(addvm.timeRange == range ? addvm.color : "bgColor"), in: RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            withAnimation {
                                addvm.timeRange = range
                            }
                        }
                }
            }
            
            Divider()
        }
    }
}

#Preview {
    TimeRangeView(addvm: .init(context: .shared))
}
