//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Никита on 04.03.2024.
//

import Foundation

struct TrackerCategory {
    
    let title: String
    let trackers: [Tracker]
    
    func visibleTrackers(filterString: String) -> [Tracker] {
        if filterString.isEmpty {
            return trackers
        } else {
            return trackers.filter { $0.name.lowercased().contains(filterString.lowercased())}
        }
    }
}
