//
//  Tracker.swift
//  Tracker
//
//  Created by Никита on 04.03.2024.
//

import Foundation
import UIKit

struct Tracker: Hashable {
    
    let id: UUID
    let name: String
    let color: UIColor?
    let emojie: String?
    let schedule: [Weekday]?
    let pinned: Bool?
    var category: TrackerCategory? {
        return TrackerCategoryStore().category(forTracker: self)
    }
}
