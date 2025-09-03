//
//  TimeRange.swift
//  HealthApp
//
//  Created by DREAMWORLD on 02/09/25.
//

import Foundation

enum TimeRange: String, CaseIterable {
    case week = "1W"
    case month = "1M"
    case sixMonths = "6M"
    case year = "1Y"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 90
        case .year: return 365
        }
    }
    
    var unit: Calendar.Component {
        switch self {
        case .week:
            return .day
        case .month:
            return .weekOfMonth
        case .sixMonths:
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
