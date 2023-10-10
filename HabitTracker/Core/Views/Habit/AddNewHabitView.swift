//
//  AddNewHabitView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 28/09/23.
//

import SwiftUI

struct AddNewHabitView: View {
    @Environment(\.dismiss) var dismiss
    @State var addVm: AddNewHabitViewModel
    //  @State var isRepeat: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: addVm.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20)
                            .padding()
                            .background(Color(addVm.color), in: RoundedRectangle(cornerRadius: 12))
                        
                        TextField("Name", text: $addVm.name)
                            .padding()
                            .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    TextField("Note", text: $addVm.note)
                        .padding()
                        .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                        .lineLimit(2)
                    
                    colorPicker
                    
                    Divider()
                }
                
                goalView
                
                TimeRangeView(addvm: addVm)
                
                FrequencyView(addvm: addVm)
                
                remainderOn
                
                habitPeriod
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            do {
                                try await addVm.addNewHabitForDaily()
                                dismiss()
                            } catch {
                                print("Error \(error)")
                            }
                        }
                    }, label: {
                        Text("Add")
                    })
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        let preview = PersistenceController.shared
        AddNewHabitView(addVm: .init(context: preview))
            .environment(\.managedObjectContext, preview.viewContext)
    }
}

extension AddNewHabitView {
    var colorPicker: some View {
        HStack {
            ForEach(1...7, id:\.self) { index in
                let color = "card-\(index)"
                Circle()
                    .fill(Color(color))
                    .frame(width: 40)
                    .overlay(content: {
                        if addVm.color == color {
                            Image(systemName: "checkmark")
                        }
                    })
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        addVm.color = "card-\(index)"
                        print(addVm.color)
                    }
            }
        }
    }
    
    //    var timeRange: some View {
    //        VStack(alignment: .leading, spacing: 14) {
    //            Text("Time range")
    //                .bold()
    //
    //            TimeRangeView(addvm: addVm)
    //            Divider()
    //        }
    //    }
    
    var goalView: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Toggle(isOn: $addVm.hasGoalSet) {
                Text("Set Goal")
                    .bold()
            }
            
            //            HStack {
            //                Text("Goal")
            //                    .bold()
            //
            //                Spacer()
            //
            //                Text("/ per day")
            //                    .font(.footnote)
            //                    .foregroundStyle(.gray)
            //            }
            
            if addVm.hasGoalSet {
                HStack(spacing: 14) {
                    TextField("30", text: $addVm.note)
                        .padding()
                        .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                        .lineLimit(2)
                    
                    TextField("mins", text: $addVm.note)
                        .padding()
                        .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                        .lineLimit(2)
                }
            }
            Divider()
        }
    }
    
    //    var repeatView: some View {
    //        VStack(alignment: .leading, spacing: 14) {
    //            Toggle(isOn: $addVm.isRepeat) {
    //                VStack(alignment: .leading, spacing: 8) {
    //                    Text("Repeat")
    //                        .bold()
    //
    //                    Text("Never")
    //                        .font(.footnote)
    //                        .foregroundStyle(.gray)
    //                }
    //            }
    //
    //            if addVm.isRepeat {
    //                VStack(alignment: .leading, spacing: 14) {
    //                    Text("Frequency")
    //                        .bold()
    //
    //                    FrequencyView(addvm: addVm)
    //                }
    //                .animation(.easeInOut, value: addVm.isRepeat)
    //            }
    //            Divider()
    //        }
    //    }
    
    var remainderOn: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $addVm.remainderOn) {
                Text("Remainder On")
                    .bold()
            }
            
            if addVm.remainderOn {
                HStack(alignment: .center) {
                    DatePicker(selection: $addVm.remainderDate, displayedComponents: .hourAndMinute) { }
                        .labelsHidden()
                    //                    Text(.now, style: .time)
                    //                        .padding()
                    //                        .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                    //
                    TextField("Remainder Text", text: $addVm.remainderText)
                        .padding()
                        .background(Color("bgColor"), in: RoundedRectangle(cornerRadius: 12))
                }
                .animation(.easeIn, value: addVm.remainderOn)
            }
            
            Divider()
        }
    }
    
    var habitPeriod: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Habit period")
                .bold()
            
            DatePicker(selection: $addVm.startDate, displayedComponents: .date) {
                Text("Start date")
            }
            // .datePickerStyle(GraphicalDatePickerStyle())
            
            Toggle(isOn: $addVm.hasEndDateEnabled) {
                Text("End date")
                    .bold()
            }
            
            if addVm.hasEndDateEnabled {
//                DatePicker(selection: .constant(.now), displayedComponents: .date) {
//                    Text("End date")
//                }
                DatePicker("", selection: $addVm.endDate, displayedComponents: .date)
            }
        }
    }
}
