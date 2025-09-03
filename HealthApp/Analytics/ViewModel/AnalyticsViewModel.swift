//
//  AnalyticsViewModel.swift
//  HealthApp
//
//  Created by DREAMWORLD on 02/09/25.
//

import SwiftUI

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var dailyData: [DailyProgress] = []
    
    func getDates(for range: TimeRange) -> [Date] {
        return aggregatedData(for: range).map { $0.date.startOfDay }
    }
    
    func aggregatedData(for range: TimeRange) -> [DailyProgress] {
        switch range {
        case .week:
            return getWeekData()
        case .month:
            return getMonthData()
        case .sixMonths:
            return getSixMonthsData()
        case .year:
            return getYearData()
        }
    }
    
    func getWeekData() -> [DailyProgress] {
        let calendar = Calendar.current
        let today = Date()
        var weekData: [DailyProgress] = []
        
        // Get last 7 days including today
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let steps = dailyData.first { calendar.isDate($0.date, inSameDayAs: date) }?.steps ?? 0
                weekData.append(DailyProgress(date: date, steps: steps))
            }
        }
        
        return weekData.reversed() // Reverse to show oldest to newest
    }
    
    func getMonthData() -> [DailyProgress] {
        let calendar = Calendar.current
        let today = Date()
        var monthData: [DailyProgress] = []
        
        // Get last 30 days including today
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let steps = dailyData.first { calendar.isDate($0.date, inSameDayAs: date) }?.steps ?? 0
                monthData.append(DailyProgress(date: date, steps: steps))
            }
        }
        
        return monthData.reversed()
    }
    
    func getSixMonthsData() -> [DailyProgress] {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate last 6 months start dates
        var months: [Date] = []
        for i in (0..<6).reversed() { // oldest first
            if let date = calendar.date(byAdding: .month, value: -i, to: today),
               let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) {
                months.append(monthStart)
            }
        }
        
        // Group dailyData by month start date
        let grouped = Dictionary(grouping: dailyData) { item -> Date in
            let components = calendar.dateComponents([.year, .month], from: item.date)
            return calendar.date(from: components)!
        }
        
        // Map to DailyProgress for all 6 months
        let result = months.map { monthStart -> DailyProgress in
            let items = grouped[monthStart] ?? []
            let totalSteps = items.map(\.steps).reduce(0, +)
            return DailyProgress(date: monthStart, steps: totalSteps)
        }
        
        return result
    }
    
    func getYearData() -> [DailyProgress] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // Filter current year data and group by month
        let grouped = Dictionary(grouping: dailyData.filter {
            calendar.component(.year, from: $0.date) == currentYear
        }) { item in
            calendar.component(.month, from: item.date)
        }
        
        // Create entries for all 12 months
        var yearData: [DailyProgress] = []
        for month in 1...12 {
            if let items = grouped[month], !items.isEmpty {
                if let firstDate = items.first?.date {
                    yearData.append(DailyProgress(
                        date: firstDate,
                        steps: items.map(\.steps).reduce(0, +)
                    ))
                }
            } else {
                // Create placeholder for months with no data
                if let date = calendar.date(from: DateComponents(year: currentYear, month: month, day: 15)) {
                    yearData.append(DailyProgress(date: date, steps: 0))
                }
            }
        }
        
        return yearData.sorted { $0.date < $1.date }
    }
    
    // MARK: - Chart Axis
    func xAxisDesiredCount(for range: TimeRange) -> Int {
        switch range {
        case .week: return 7
        case .month: return 15
        case .sixMonths: return 6
        case .year: return 12
        }
    }
    
    func xAxisLabel(for date: Date, range: TimeRange) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        switch range {
        case .week:
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        case .month:
            let day = calendar.component(.day, from: date)
            return "\(day)"
        case .sixMonths:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .year:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
    }
    
    func yAxisStride(for data: [DailyProgress]) -> Double {
        let maxValue = yAxisMax(for: data)
        return maxValue / 5 // 5 labels evenly spaced
    }
    
    func yAxisMax(for data: [DailyProgress]) -> Double {
        guard let max = data.map(\.steps).max(), max > 0 else {
            return 1000 // Default max if no data
        }
        // Round up to nearest 1000 for better labels
        return ceil(Double(max) / 1000) * 1000
    }
    
    // Duration label for each filter
    func durationLabel(for range: TimeRange) -> String {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        switch range {
        case .week:
            guard let startDate = calendar.date(byAdding: .day, value: -6, to: today) else {
                return "This week"
            }
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: today))"
            
        case .month:
            guard let startDate = calendar.date(byAdding: .day, value: -29, to: today) else {
                return "This month"
            }
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: today))"
            
        case .sixMonths:
            guard let startDate = calendar.date(byAdding: .month, value: -5, to: today) else {
                return "Last 6 months"
            }
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: today))"
            
        case .year:
            guard let startOfYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: today), month: 1, day: 1)) else {
                return "This year"
            }
            return "\(formatter.string(from: startOfYear)) - \(formatter.string(from: today))"
        }
    }
}
