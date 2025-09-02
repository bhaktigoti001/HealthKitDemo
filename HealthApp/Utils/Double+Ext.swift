//
//  Double+Ext.swift
//  HealthApp
//
//  Created by DREAMWORLD on 01/09/25.
//

import Foundation

extension Double {
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
    
    func formatDuration() -> String {
        let seconds = Int(self * 3600)
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        return "\(hrs)h \(mins)m"
    }
}
