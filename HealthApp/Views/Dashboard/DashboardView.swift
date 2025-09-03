//
//  DashboardView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var showingManualEntry = false
    @State private var manualSteps = ""
    
    private let dailyGoal: Double = 10000
    private let weeklyGoal: Double = 70000
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Step Counter with Progress
                    VStack(spacing: 20) {
                        Text("Today's Steps")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: min(healthKitManager.stepCount / dailyGoal, 1))
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: healthKitManager.stepCount)
                            
                            VStack {
                                Text("\(Int(healthKitManager.stepCount))")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("of \(Int(dailyGoal))")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Text("\(Int((healthKitManager.stepCount / dailyGoal) * 100))% of daily goal")
                            .font(.headline)
                    }
                    .padding()
                    
                    // Health Metrics Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        MetricCard(title: "Heart Rate", value: "\(Int(healthKitManager.heartRate))", unit: "BPM", icon: "heart", color: .red)
                        MetricCard(title: "Active Energy", value: String(format: "%.2f", healthKitManager.activeEnergy), unit: "kcal", icon: "flame", color: .orange)
                        MetricCard(title: "Sleep", value: String(format: "%.1f", healthKitManager.sleepHours), unit: "hours", icon: "bed.double", color: .purple)
                        SyncStatusCard(lastSync: healthKitManager.lastSyncDate, isSyncing: healthKitManager.isSyncing)
                    }
                    
                    // Weekly Progress
                    WeeklyProgressView(weeklyGoal: weeklyGoal)
                        .environmentObject(healthKitManager)
                    
                    // Devices
                    DevicesView(devices: healthKitManager.devices)
                    
                    // Manual Entry Button
                    Button("Add Manual Steps") {
                        showingManualEntry = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            )
            .navigationTitle("Health Dashboard")
            .refreshable {
                healthKitManager.fetchAllHealthData()
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualEntryView(manualSteps: $manualSteps) { steps in
                    healthKitManager.addManualSteps(steps) { success in
                        showingManualEntry = false
                    }
                }
            }
            .onAppear(perform: {
                healthKitManager.fetchAllHealthData()
            })
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    healthKitManager.fetchAllHealthData()
                }
            }
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
