//
//  Date+Ext.swift
//  HealthApp
//
//  Created by DREAMWORLD on 03/09/25.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension DateFormatter {
    static let shortDay: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df
    }()
    
    static let shortMonth: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df
    }()
}
