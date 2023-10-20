//
//  FrequencyView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 04/10/23.
//

import SwiftUI

enum Frequency: String, Identifiable, CaseIterable {
    var id: String {
        rawValue
    }
    
    case daily, weekly, monthly
}

struct FrequencyView: View {
    @Bindable var addvm: AddNewHabitViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Frequency")
                .bold()
            
            HStack {
                ForEach(Frequency.allCases) { frequent in
                    Text(frequent.rawValue.capitalized)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(addvm.frequency == frequent ? addvm.color : "bgColor"), in: RoundedRectangle(cornerRadius: 12))
                    //.background(addvm.frequency == frequent.rawValue ? Color.gray : .clear)
                        .onTapGesture {
                            withAnimation {
                                addvm.frequency = frequent
                            }
                            
                        }
                }
            }
            
            Divider()
            
            let weekDays = Calendar.current.weekdaySymbols
            ZStack {
                Group {
                    if addvm.frequency == .daily {
                        Text("Every day")
                    } else if addvm.frequency == .weekly {
                        HStack {
                            ForEach(weekDays, id:\.self) { day in
                                let index = addvm.savedWeekDays.firstIndex { value in
                                    value == day
                                } ?? -1
                                
                                Text(day.prefix(3))
                                // .frame(width: 40, height: 40)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(content: {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(index != -1 ? Color(addvm.color) : Color("bgColor"))
                                    })
                                    .onTapGesture {
                                        if index != -1 {
                                            addvm.savedWeekDays.remove(at: index)
                                        } else {
                                            addvm.savedWeekDays.append(day)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            Divider()
        }
        .animation(.easeInOut, value: addvm.isRepeat)
    }
}


#Preview {
    FrequencyView(addvm: .init(provider: .shared))
}
