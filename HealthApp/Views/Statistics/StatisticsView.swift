//
//  StatisticsView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 01/09/25.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var hk: HealthKitManager
    @State private var stats = UserStats()
    @State private var achievements: [Achievements] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Personal Statistics
                Text("Your Statistics")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                statisticsCard
                
                // MARK: - Achievements
                Text("Achievements")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                achievementsScroll
                
            }
            .padding(.top)
        }
        .background(LinearGradient(
            colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
            startPoint: .top,
            endPoint: .bottom
        ).ignoresSafeArea())
        .onAppear { loadData() }
    }
    
    // MARK: - Statistics Card
    private var statisticsCard: some View {
        VStack(spacing: 16) {
            StatRow(title: "Steps Today", value: "\(Int(stats.stepsToday))")
            StatRow(title: "Best Steps Day", value: "\(Int(stats.bestStepsDay))")
            StatRow(title: "Average Daily Steps", value: "\(Int(stats.avgSteps))")
            
            Divider()
            
            StatRow(title: "Resting HR", value: "\(Int(stats.restingHR)) bpm")
            StatRow(title: "Max HR", value: "\(Int(stats.maxHR)) bpm")
            
            Divider()
            
            StatRow(title: "Average Sleep", value: "\(formatDuration(stats.avgSleep))")
            StatRow(title: "Best Sleep", value: "\(formatDuration(stats.bestSleep))")
            
            Divider()
            
            StatRow(title: "Active Energy", value: "\(Int(stats.activeEnergyToday)) kcal")
            StatRow(title: "Best Energy Day", value: "\(Int(stats.bestActiveEnergy)) kcal")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    var achievementsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(achievements) { achievement in
                    VStack(spacing: 8) {
                        Image(systemName: achievement.achieved ? "star.fill" : "star")
                            .font(.largeTitle)
                            .foregroundColor(achievement.achieved ? .yellow : .gray)
                        Text(achievement.title)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: 100, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    func loadData() {
        hk.fetchStatistics { stats in
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
    
    func formatDuration(_ hours: Double) -> String {
        let seconds = Int(hours * 3600)
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        return "\(hours)h \(mins)m"
    }
}
