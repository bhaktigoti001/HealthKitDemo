//
//  AnalyticsView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI
import DGCharts

struct AnalyticsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = AnalyticsViewModel()
    @EnvironmentObject var hk: HealthKitManager
    @State private var selectedMetric: HealthMetric = .steps
    @State private var selectedRange: TimeRange = .week
    @State private var hasData = false

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Health Analytics")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 12)
            
            Picker("Metric", selection: $selectedMetric) {
                ForEach(HealthMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Picker("Range", selection: $selectedRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("\(selectedMetric.rawValue) over \(selectedRange.rawValue)")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text(viewModel.durationLabel(for: selectedRange))
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.top, -8)
                
                if hasData {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        DGBarChart(data: viewModel.aggregatedData(for: selectedRange), range: selectedRange)
                            .frame(height: 320)
                            .padding(.horizontal)
                    }
                } else {
                    noDataView()
                }
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
        .onAppear(perform: {
            loadData()
        })
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active { loadData() }
        }
        .onChange(of: selectedMetric) { _ in loadData() }
        .onChange(of: selectedRange) { _ in loadData() }
    }

    @ViewBuilder
    func noDataView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Data Available")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("We couldn't find any \(selectedMetric.rawValue.lowercased()) data for the selected period.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") { loadData() }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.top, 8)
        }
        .frame(height: 320)
        .padding(.horizontal)
    }

    private func loadData() {
        hk.fetchMetricData(metric: selectedMetric, range: selectedRange) { data in
            viewModel.dailyData = data
            let maxStep = data.map({ $0.steps }).max() ?? 0.0
            hasData = maxStep > 0
        }
    }
}
