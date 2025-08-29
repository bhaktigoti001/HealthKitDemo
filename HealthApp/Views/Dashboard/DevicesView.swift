//
//  DevicesView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI
import HealthKit

struct DevicesView: View {
    let devices: [HKDevice]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Connected Devices")
                .font(.headline)
                .padding(.horizontal)
            
            if devices.isEmpty {
                Text("No devices found")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(devices, id: \.name) { device in
                    HStack {
                        Image(systemName: "applewatch")
                        VStack(alignment: .leading) {
                            Text(device.name ?? "Unknown Device")
                                .fontWeight(.semibold)
                            if let model = device.model {
                                Text(model)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
