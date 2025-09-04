//
//  StatisticsViewModel.swift
//  HealthApp
//
//  Created by DREAMWORLD on 04/09/25.
//

import SwiftUI

class StatisticsViewModel: ObservableObject {
    
    func evaluateAchievements(from stats: UserStats, dailyGoal: Double) -> [Achievements] {
        [
            Achievements(title: "\(formatNumber(dailyGoal)) Steps in a Day",
                        description: "Walked 10,000 steps in a single day",
                         achieved: stats.stepsToday >= dailyGoal),
            Achievements(title: "7+ Hours Sleep",
                        description: "Slept at least 7 hours",
                        achieved: (stats.avgSleep * 3600) >= 25_200), // 7 * 3600
            Achievements(title: "Burn 500 kcal",
                        description: "Burned 500 active kcal in a day",
                        achieved: stats.activeEnergyToday >= 500)
        ]
    }
    
    func formatNumber(_ number: Double) -> String {
        let absNumber = abs(number)
        let sign = number < 0 ? "-" : ""
        
        switch absNumber {
        case 1_000_000...:
            let formatted = absNumber / 1_000_000
            return "\(sign)\(String(format: "%.1f", formatted))M"
        case 1_000...:
            let formatted = absNumber / 1_000
            return "\(sign)\(String(format: "%.1f", formatted))K"
        default:
            return "\(sign)\(Int(absNumber))"
         }
    }
}
