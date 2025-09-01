//
//  StatRow.swift
//  HealthApp
//
//  Created by DREAMWORLD on 01/09/25.
//

import SwiftUI

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}
