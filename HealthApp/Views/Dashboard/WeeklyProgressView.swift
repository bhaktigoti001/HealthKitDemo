//
//  WeeklyProgressView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI

enum TimeRange: String, CaseIterable {
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case year = "1Y"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
    
    var unit: Calendar.Component {
        switch self {
        case .week:
            return .day
        case .month:
            return .weekOfMonth
        case .threeMonths:
            return .weekOfMonth
        case .year:
            return .month
        }
    }
}

enum HealthMetric: String, CaseIterable {
    case steps = "Steps"
    case heartRate = "Heart Rate"
    case sleep = "Sleep"
    case activeEnergy = "Active Energy"
}

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
                
                Text("\(Int((healthKitManager.weeklyProgress.totalSteps / weeklyGoal) * 100))%")
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
                        .frame(width: 60, height: 60)
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

