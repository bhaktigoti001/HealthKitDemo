//
//  Device.swift
//  HealthApp
//
//  Created by DREAMWORLD on 04/09/25.
//

import Foundation

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let isConnected: Bool
}
