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
        VStack(alignment: devices.isEmpty ? .center : .leading) {
            Text("Connected Devices")
                .font(.headline)
                .padding(.horizontal)
            
            if devices.isEmpty {
                Text("No devices found")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(devices, id: \.udiDeviceIdentifier) { device in
                    HStack(spacing: 12) {
                        Image(systemName: device.deviceIcon)
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name ?? "Unknown Device")
                                .fontWeight(.semibold)
                            
                            if let model = device.hardwareVersion {
                                Text(model)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            if let version = device.softwareVersion {
                                Text("iOS \(version)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
