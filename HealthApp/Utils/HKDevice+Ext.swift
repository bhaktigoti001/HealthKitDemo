//
//  HKDevice+Ext.swift
//  HealthApp
//
//  Created by DREAMWORLD on 04/09/25.
//

import HealthKit

extension HKDevice {
    var deviceIcon: String {
        let identifier = (model ?? name ?? "").lowercased()
        
        if identifier.contains("iphone") {
            return "iphone"
        } else if identifier.contains("watch") {
            return "applewatch"
        } else if identifier.contains("ipad") {
            return "ipad"
        } else if identifier.contains("mac") {
            return "laptopcomputer"
        }
        return "questionmark.circle"
    }
}
