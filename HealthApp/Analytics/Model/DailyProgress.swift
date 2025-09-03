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
    
    static func dataEntriesForAnalytics(progress: [DailyProgress]) -> [BarChartDataEntry] {
        return progress.map({ BarChartDataEntry(x: $0.date.timeIntervalSince1970, y: $0.steps) })
    }
}

struct WeeklyProgress {
    let days: [DailyProgress]
    var totalSteps: Double {
        days.reduce(0) { $0 + $1.steps }
    }
}
