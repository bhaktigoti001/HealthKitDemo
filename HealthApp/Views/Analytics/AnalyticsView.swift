//
//  AnalyticsView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var hk: HealthKitManager
    
    @State private var selectedMetric: HealthMetric = .steps
    @State private var selectedRange: TimeRange = .week
    @State private var dailyData: [DailyProgress] = []
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Screen Title
            Text("Health Analytics")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 12)
            
            // Metric Tabs
            Picker("Metric", selection: $selectedMetric) {
                ForEach(HealthMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Range Picker
            Picker("Range", selection: $selectedRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Chart Card
            VStack(alignment: .leading, spacing: 12) {
                Text("\(selectedMetric.rawValue) over \(selectedRange.rawValue)")
                    .font(.headline)
                    .padding(.horizontal)
                
                createChart()

            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .background(
                        LinearGradient(
                            colors: [Color.white, Color.gray.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(18)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                loadData()
            }
        }
        .onChange(of: selectedMetric) { _ in loadData() }
        .onChange(of: selectedRange) { _ in loadData() }
    }
    
    @ViewBuilder
    func createChart() -> some View {
        Chart {
            ForEach(aggregatedData(for: selectedRange)) { day in
                BarMark(
                    x: .value("Day", day.date),
                    y: .value(selectedMetric.rawValue, day.steps)
                )
//                .barWidth(barWidth(for: selectedRange))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple],
                                   startPoint: .bottom,
                                   endPoint: .top)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
        }
        .chartXAxis {
            AxisMarks(values: xAxisStride(for: selectedRange)) { value in
                AxisGridLine()
                AxisValueLabel(format: xAxisFormat(for: selectedRange))
            }
        }
        .frame(height: 320)
        .padding(.horizontal)
    }
    
    func aggregatedData(for range: TimeRange) -> [DailyProgress] {
        switch range {
        case .week:
            return dailyData
        case .month, .threeMonths:
            return groupByWeek(dailyData)
        case .year:
            return groupByMonth(dailyData)
        }
    }

    func groupByWeek(_ data: [DailyProgress]) -> [DailyProgress] {
        let grouped = Dictionary(grouping: data) { item in
            Calendar.current.component(.weekOfYear, from: item.date)
        }
        return grouped.map { (_, items) in
            DailyProgress(
                date: items.first!.date,
                steps: items.map(\.steps).reduce(0, +)
            )
        }
        .sorted { $0.date < $1.date }
    }

    func groupByMonth(_ data: [DailyProgress]) -> [DailyProgress] {
        let grouped = Dictionary(grouping: data) { item in
            Calendar.current.component(.month, from: item.date)
        }
        return grouped.map { (_, items) in
            DailyProgress(
                date: items.first!.date,
                steps: items.map(\.steps).reduce(0, +)
            )
        }
        .sorted { $0.date < $1.date }
    }

    func barWidth(for range: TimeRange) -> CGFloat {
        switch range {
        case .week:
            return 20
        case .month, .threeMonths:
            return 10
        case .year:
            return 4
        }
    }
    
    // MARK: - Chart Axis
    func xAxisStride(for range: TimeRange) -> AxisMarkValues {
        switch range {
        case .week:
            return .stride(by: .day)
        case .month:
            return .stride(by: .day, count: 5)
        case .threeMonths:
            return .stride(by: .month)
        case .year:
            return .stride(by: .month, count: 3)
        }
    }
    
    func xAxisFormat(for range: TimeRange) -> Date.FormatStyle {
        switch range {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day(.defaultDigits)
        case .threeMonths, .year:
            return .dateTime.month(.abbreviated)
        }
    }
    
    // MARK: - Data Loading
    private func loadData() {
        hk.fetchMetricData(metric: selectedMetric, range: selectedRange) { data in
            self.dailyData = data
        }
    }
}

