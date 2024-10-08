//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Никита on 04.03.2024.
//

import Foundation

struct TrackerCategory: Hashable {
    
    let title: String
    let trackers: [Tracker]
    
    func visibleTrackers(filterString: String, pin: Bool?) -> [Tracker] {
        if filterString.isEmpty {
            return trackers
        } else {
            return trackers.filter { $0.name.lowercased().contains(filterString.lowercased())}
        }
    }
}
