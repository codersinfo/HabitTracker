//
//  CircularStepperView.swift
//  HabitTracker
//
//  Created by Priya Shankar on 13/10/23.
//

//TODO: adding notification when finishes with haptic and sound

import SwiftUI

struct CircularStepperView: View {
    @State private var progress: Double = 0.0001
    @State private var remainingCount: Int = 0
    @State private var isPresented: Bool = false
    @State private var addCountText: String = ""
    private var totalCount: Int
    
    init(totalCount: Int = 0) {
        self.totalCount = totalCount
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressRing(progress: $progress, primaryColor: .yellow) {
                VStack(spacing: 12) {
                    Text("\(remainingCount)")
                        .bold()
                        .font(.largeTitle)
                    
                    Text("\(totalCount)")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.bottom, 40)
            
            HStack(spacing: 20) {
                Button {
                    addToCount()
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        //.aspectRatio(contentMode: .fit)
                        //.frame(width: 30, height: 30)
                        //.padding(10)
//                        .background(
//                            Circle()
//                                .fill(.white)
//                                .shadow(color: .black.opacity(0.1), radius: 10)
//                        )
                }
                
                Button {
                    reset()
                } label: {
                    Image(systemName: "arrow.clockwise.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                Button {
                    isPresented = true
                } label: {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
        }
        //        .onAppear(perform: {
        //            withAnimation(.easeInOut(duration: 0.25)) {
        //                defaultCount()
        //            }
        //        })
        .sheet(isPresented: $isPresented, content: {
            HStack(content: {
                TextField("Count", text: $addCountText)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(.rect(cornerRadius: 12))
                // .padding(.horizontal)
                
                Button(action: {
                    updateCount()
                }, label: {
                    Text("Add")
                        .padding()
                        .background(Color.mint)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 12))
                })
                
            })
            .padding(.horizontal)
            .presentationDetents([.height(200)])
            .presentationCornerRadius(12)
        })
    }
    
    private func updateCount() {
        isPresented = false
        if !addCountText.isEmpty {
            guard let convertedCount = Int(addCountText) else { return }
            
            withAnimation(.easeInOut(duration: 0.25)) {
                if convertedCount > 0 {
                    remainingCount += convertedCount
                    progress = CGFloat(remainingCount) / CGFloat(totalCount)
                }
            }
            addCountText = ""
        }
    }
    
    private func addToCount() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if remainingCount < totalCount {
                remainingCount += 1
                progress = CGFloat(remainingCount) / CGFloat(totalCount)
            }
        }
    }
    
    private func reset() {
        withAnimation(.easeInOut(duration: 0.25)) {
            remainingCount = 0
            progress = 0.0001
        }
    }
}


#Preview {
    CircularStepperView(totalCount: 20)
}
