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
    
    var progress: Double {
        min(healthKitManager.weeklyProgress.totalSteps / weeklyGoal, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Title Row
            HStack {
                Text("Weekly Progress")
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.1f%%", (healthKitManager.weeklyProgress.totalSteps / weeklyGoal) * 100))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            // Progress Info
            HStack {
                (
                    Text("\(Int(healthKitManager.weeklyProgress.totalSteps))")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    +
                    Text(" of \(Int(weeklyGoal)) steps")
                        .foregroundColor(.secondary)
                )
                Spacer()
            }
            
            // Progress Bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 6)
                .cornerRadius(3)
            
            // Daily Breakdown
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(healthKitManager.weeklyProgress.days) { day in
                        VStack(spacing: 6) {
                            Text(day.date, format: .dateTime.weekday(.abbreviated))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(day.steps))")
                                .fontWeight(.semibold)
                                .foregroundColor(day.steps > 0 ? .blue : .gray)
                        }
                        .padding(.horizontal, 8)
                        .frame(minWidth: 60, minHeight: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(day.steps > 0 ? 0.12 : 0.05))
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        .onAppear {
            healthKitManager.fetchWeeklySteps { progress in
                healthKitManager.weeklyProgress = progress
            }
        }
    }
}
