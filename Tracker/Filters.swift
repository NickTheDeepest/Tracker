//
//  Filters.swift
//  Tracker
//
//  Created by Никита on 13.03.2024.
//

import Foundation

enum Filter: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case uncompleted = "Незавершенные"
}
