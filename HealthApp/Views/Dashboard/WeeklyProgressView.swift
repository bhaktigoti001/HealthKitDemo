//
//  WeeklyProgressView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI

struct WeeklyProgressView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager

    let weeklyGoal: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Weekly Progress")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                (
                    Text("\(Int(healthKitManager.weeklyProgress.totalSteps))")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    +
                    Text(" of \(Int(weeklyGoal)) steps")
                        .foregroundColor(.gray)
                        .font(.caption)
                )
                
                Spacer()
                
                Text(String(format: "%.1f", ((healthKitManager.weeklyProgress.totalSteps / weeklyGoal) * 100)) + "%")
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            ProgressView(value: min(healthKitManager.weeklyProgress.totalSteps / weeklyGoal, 1))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(healthKitManager.weeklyProgress.days) { day in
                        VStack {
                            Text(day.date, format: .dateTime.weekday(.abbreviated))
                                .font(.caption)
                            
                            Text("\(Int(day.steps))")
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 8)
                        .frame(minWidth: 60, minHeight: 60)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .onAppear {
            healthKitManager.fetchWeeklySteps { progress in
                healthKitManager.weeklyProgress = progress
            }
        }
    }
}

