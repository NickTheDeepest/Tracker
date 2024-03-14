//
//  Analytics.swift
//  Tracker
//
//  Created by Никита on 13.03.2024.
//

import Foundation
import YandexMobileMetrica

enum ScreenName: String {
    case main = "Main"
    case statistics = "Statistics"
}

struct Analytics {
    
    func openScreenReport(screen: ScreenName) {
        report(event: "open", params: ["screen" : "\(screen)"])
    }
    
    func closeScreenReport(screen: ScreenName) {
        report(event: "close", params: ["screen" : "\(screen)"])
    }
    
    func addTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "add_track"])
    }
    
    func addFilterReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "filter"])
    }
    
    func editTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "edit"])
    }
    
    func deleteTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "delete"])
    }
    
    func clickRecordTrackReport() {
        report(event: "click", params: ["screen" : "Main", "item" : "track"])
    }
    
    private func report(event: String, params: [AnyHashable : String]) {
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("REPORT ERROR %@", error.localizedDescription)
        }
    }
}
