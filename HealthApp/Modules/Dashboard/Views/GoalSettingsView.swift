//
//  GoalSettingsView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 04/09/25.
//

import SwiftUI

struct GoalSettingsView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var dailyGoal: Double = 10000
    @State private var weeklyGoal: Double = 70000
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Header
                Text("Goal Settings")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Daily Goal Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "figure.walk.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 28))
                        Text("Daily Step Goal")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(dailyGoal))")
                            .font(.title3.bold())
                            .foregroundColor(.blue)
                    }
                    
                    Slider(value: $dailyGoal, in: 2000...20000, step: 500)
                        .accentColor(.blue)
                    
                    Text("Set a daily goal that motivates you to stay active.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 3)
                .padding(.horizontal)
                
                // Weekly Goal Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 28))
                        Text("Weekly Step Goal")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(weeklyGoal))")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                    }
                    
                    Slider(value: $weeklyGoal, in: 10000...150000, step: 1000)
                        .accentColor(.green)
                    
                    Text("Set a weekly goal to build healthy consistency.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 3)
                .padding(.horizontal)
                
                // Save Button
                Button(action: {
                    goalManager.dailyGoal = dailyGoal
                    goalManager.weeklyGoal = weeklyGoal
                    dismiss()
                }) {
                    Text("Save Goals")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .opacity(dailyGoal == goalManager.dailyGoal && weeklyGoal == goalManager.weeklyGoal ? 0 : 1)
            }
            .onAppear {
                dailyGoal = Double(goalManager.dailyGoal)
                weeklyGoal = Double(goalManager.weeklyGoal)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
