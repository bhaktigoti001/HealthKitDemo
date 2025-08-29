//
//  MainTabView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared

    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(healthKitManager)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            AnalyticsView()
                .environmentObject(healthKitManager)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
        }
    }
}
