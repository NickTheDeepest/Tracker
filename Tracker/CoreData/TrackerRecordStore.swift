//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Никита on 06.03.2024.
//

import Foundation
import CoreData

class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    static let shared = TrackerRecordStore()
    
    convenience init() {
        let context = DatabaseManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
    }
    
    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with record: TrackerRecord) {
        trackerRecordCoreData.id = record.id
        trackerRecordCoreData.date = record.date
    }
    
    func fetchTrackerRecord() throws -> [TrackerRecord] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let trackerRecordFromCoreData = try context.fetch(fetchRequest)
        return try trackerRecordFromCoreData.map { try self.trackerRecord(from: $0) }
    }
    
    func trackerRecord(from data: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = data.id else {
            throw DatabaseError.someError
        }
        guard let date = data.date else {
            throw DatabaseError.someError
        }
        return TrackerRecord(
            id: id,
            date: date
        )
    }
}
