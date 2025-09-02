//
//  AchievementBadge.swift
//  HealthApp
//
//  Created by DREAMWORLD on 01/09/25.
//

import SwiftUI

struct AchievementBadge: View {
    @Binding var achievement: Achievements
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.achieved ? "star.fill" : "star")
                .font(.largeTitle)
                .foregroundColor(achievement.achieved ? .yellow : .gray)
            
            Text(achievement.title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.achieved ? .primary : .secondary)
        }
        .padding()
        .frame(width: 100, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.achieved ? Color.yellow : Color.gray, lineWidth: 1)
        )
    }
}
