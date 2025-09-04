//
//  SyncStatusCard.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI

struct SyncStatusCard: View {
    let lastSync: Date
    let isSyncing: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Last Sync")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    .foregroundStyle(.gray)
            }
            .padding(.bottom, 4)
            
            if isSyncing {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                Text(lastSync, style: .time)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(isSyncing ? "Syncing..." : "Auto sync every 15min")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
