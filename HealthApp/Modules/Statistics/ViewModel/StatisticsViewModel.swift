//
//  StatisticsViewModel.swift
//  HealthApp
//
//  Created by DREAMWORLD on 04/09/25.
//

import SwiftUI

class StatisticsViewModel: ObservableObject {
    
    func evaluateAchievements(from stats: UserStats) -> [Achievements] {
        [
            Achievements(title: "10K Steps in a Day",
                        description: "Walked 10,000 steps in a single day",
                        achieved: stats.stepsToday >= 10_000),
            Achievements(title: "7+ Hours Sleep",
                        description: "Slept at least 7 hours",
                        achieved: (stats.avgSleep * 3600) >= 25_200), // 7 * 3600
            Achievements(title: "Burn 500 kcal",
                        description: "Burned 500 active kcal in a day",
                        achieved: stats.activeEnergyToday >= 500)
        ]
    }
}
