//
//  HealthData.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI

// MARK: - Data Models
struct HealthData {
    var steps: Double
    var heartRate: Double
    var activeEnergy: Double
    var sleepHours: Double
    var lastSync: Date
}

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let isConnected: Bool
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isUnlocked: Bool
    let progress: Double
}
