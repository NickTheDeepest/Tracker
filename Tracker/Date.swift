//
//  Date.swift
//  Tracker
//
//  Created by Никита on 05.03.2024.
//

import Foundation

extension Date {
    var yearMonthDayComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
