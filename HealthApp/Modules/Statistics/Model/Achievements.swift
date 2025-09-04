//
//  Achievements.swift
//  HealthApp
//
//  Created by DREAMWORLD on 04/09/25.
//

import Foundation

struct Achievements: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let achieved: Bool
}
