//
//  GoalManager.swift
//  HealthApp
//
//  Created by DREAMWORLD on 04/09/25.
//

import SwiftUI

class GoalManager: ObservableObject {
    @AppStorage("dailyGoal") var dailyGoal: Double = 10000
    @AppStorage("weeklyGoal") var weeklyGoal: Double = 70000
    
    static let shared = GoalManager()
    
    // Example helper
    func progress(todaySteps: Double, weeklySteps: Double) -> (daily: Double, weekly: Double) {
        let dailyProgress = min(todaySteps / Double(dailyGoal), 1.0)
        let weeklyProgress = min(weeklySteps / Double(weeklyGoal), 1.0)
        return (dailyProgress, weeklyProgress)
    }
}
