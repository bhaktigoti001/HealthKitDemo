//
//  DailyProgress.swift
//  HealthApp
//
//  Created by DREAMWORLD on 03/09/25.
//

import DGCharts
import Foundation

struct DailyProgress: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Double
}

struct WeeklyProgress {
    let days: [DailyProgress]
    var totalSteps: Double {
        days.reduce(0) { $0 + $1.steps }
    }
}
