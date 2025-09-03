//
//  StatisticsView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 01/09/25.
//

import SwiftUI

// MARK: - Range Enum
enum DateRange {
    case today, week, month, year
}

struct StatisticsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var hk: HealthKitManager
    @State private var stats = UserStats()
    @State private var achievements: [Achievements] = []
    @State private var selectedRange: DateRange = .today

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Personal Statistics
                    Text("Your Statistics")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // MARK: - Range Selector
                    Picker("Range", selection: $selectedRange) {
                        Text("Today").tag(DateRange.today)
                        Text("Week").tag(DateRange.week)
                        Text("Month").tag(DateRange.month)
                        Text("1 Year").tag(DateRange.year)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedRange) { _ in loadData() }
                    
                    statisticsCard
                    
                    // MARK: - Achievements
                    Text("Achievements")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    achievementsScroll
                }
                .padding(.vertical)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
        )
        .onAppear(perform: {
            loadData()
        })
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                loadData()
            }
        }
    }
    
    // MARK: - Statistics Card
    private var statisticsCard: some View {
        VStack(spacing: 16) {
            StatRow(title: "Steps", value: stats.stepsToday.formattedNumberString(), icon: "figure.walk", color: .blue)
            StatRow(title: "Best Steps Day", value: stats.bestStepsDay.formattedNumberString(), icon: "trophy", color: .yellow)
            StatRow(title: "Average Daily Steps", value: stats.avgSteps.formattedNumberString(), icon: "chart.line.uptrend.xyaxis", color: .green)
            
            Divider()
            
            StatRow(title: "Heart Rate", value: "\(Int(stats.restingHR)) bpm", icon: "heart", color: .red)
            StatRow(title: "Max HR", value: "\(Int(stats.maxHR)) bpm", icon: "heart.fill", color: .pink)
            
            Divider()
            
            StatRow(title: "Average Sleep", value: stats.avgSleep.formatDuration(), icon: "moon.zzz", color: .purple)
            StatRow(title: "Best Sleep", value: stats.bestSleep.formatDuration(), icon: "bed.double.fill", color: .indigo)
            
            Divider()
            
            StatRow(title: "Active Energy", value: String(format: "%.2f", stats.activeEnergyToday) + " kcal", icon: "flame", color: .orange)
            StatRow(title: "Best Energy Day", value: String(format: "%.2f", stats.bestActiveEnergy) + " kcal", icon: "bolt.fill", color: .orange)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)).shadow(radius: 2))
        .padding(.horizontal)
    }
    
    var achievementsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach($achievements) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Fetch Data Based on Range
    func loadData() {
        hk.fetchStatistics(for: selectedRange) { stats in
            self.stats = stats
            self.achievements = evaluateAchievements(from: stats)
        }
    }
    
    private func evaluateAchievements(from stats: UserStats) -> [Achievements] {
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
