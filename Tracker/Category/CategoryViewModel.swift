//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Никита on 10.03.2024.
//

import Foundation

protocol CategoryViewModelDelegate: AnyObject {
    func createCategory(category: TrackerCategory)
}

final class CategoryViewModel: NSObject {
    
    var onChange: (() -> Void)?
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onChange?()
        }
    }
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private(set) var selectedCategory: TrackerCategory?
    private weak var delegate: CategoryViewModelDelegate?
    
    init(delegate: CategoryViewModelDelegate?, selectedCategory: TrackerCategory?) {
        self.selectedCategory = selectedCategory
        self.delegate = delegate
        super.init()
        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.trackerCategories
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        try? self.trackerCategoryStore.deleteCategory(category)
    }
    
    func selectCategory(with title: String) {
        let category = TrackerCategory(title: title, trackers: [])
        delegate?.createCategory(category: category)
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        onChange?()
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.trackerCategories
    }
}
