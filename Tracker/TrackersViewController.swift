//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Никита on 26.02.2024.
//

import Foundation
import UIKit

class TrackersViewController: UIViewController {
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var newCategories: [TrackerCategory] = []
    private var currentDate: Int?
    private var searchText: String = ""

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "1")
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = .black
        textLabel.text = "Что будем отслеживать?"
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    private lazy var datePicker = UIDatePicker()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.placeholder = "Поиск"
        searchTextField.textColor = .black
        searchTextField.font = .systemFont(ofSize: 17)
        searchTextField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        searchTextField.layer.cornerRadius = 10
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        return searchTextField
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersSupplementaryView.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        updateCategories()
        view.addSubview(imageView)
        view.addSubview(textLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 400),
            
            textLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self

    
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            title = "Трекеры"
            let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTracker))
            leftButton.tintColor = .black
            navigationBar.topItem?.setLeftBarButton(leftButton, animated: false)
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = .date
            datePicker.locale = Locale(identifier: "ru_RU")
            datePicker.calendar.firstWeekday = 2
            datePicker.accessibilityLabel = dateFormatter.string(from: datePicker.date)
            
            let rightButton = UIBarButtonItem(customView: datePicker)
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            rightButton.accessibilityLabel = dateFormatter.string(from: datePicker.date)
            navigationBar.topItem?.setRightBarButton(rightButton, animated: false)
            navigationBar.prefersLargeTitles = true
            
            
        }
    }
    
    
    private func updateCategories() {
            var freshCategories: [TrackerCategory] = []
            for category in categories {
                var newTrackers: [Tracker] = []
                for tracker in category.trackers {
                    guard let schedule = tracker.schedule else { return }
                    let scheduleInts = schedule.map { $0.numberOfDay }
                    if let day = currentDate, scheduleInts.contains(day) && (searchText.isEmpty || tracker.name.contains(searchText)) {
                        newTrackers.append(tracker)
                    }
                }
                if newTrackers.count > 0 {
                    let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                    freshCategories.append(newCategory)
                }
            }
            newCategories = freshCategories
            collectionView.reloadData()
        }
    
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let comp = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = comp.weekday {
            currentDate = day
            updateCategories()
        }
    }
    
    @objc func newTracker() {
        let trackersViewController = CreateTrackerViewController()
                trackersViewController.delegate = self
                present(trackersViewController, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return newCategories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        cell.delegate = self
        let tracker = newCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedTrackers.contains(where: { record in
            record.id == tracker.id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        })
        let isEnabled = datePicker.date < Date() || Date().yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        let completedCount = completedTrackers.filter({ record in
            record.id == tracker.id
        }).count
        cell.configure(
            tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emojie,
            isCompleted: isCompleted,
            isEnabled: isEnabled,
            completedCount: completedCount
        )
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = newCategories.count
        collectionView.isHidden = count == 0
        return count
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
                        return CGSize(width: collectionView.bounds.width / 2 - 5, height: (collectionView.bounds.width / 2 - 5) * 0.88)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
                        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
                        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersSupplementaryView else { return UICollectionReusableView() }
        view.titleLabel.text = newCategories[indexPath.section].title
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    
    func createTracker(_ tracker: Tracker, categoryName: String) {
        var categoryToUpdate: TrackerCategory?
        var index: Int?
        
        for i in 0..<categories.count {
            if categories[i].title == categoryName {
                categoryToUpdate = categories[i]
                index = i
            }
        }
        if categoryToUpdate == nil {
            categories.append(TrackerCategory(title: categoryName, trackers: [tracker]))
        } else {
            let trackerCategory = TrackerCategory(title: categoryName, trackers: [tracker] + (categoryToUpdate?.trackers ?? []))
            categories.remove(at: index ?? 0)
            categories.append(trackerCategory)
        }
        newCategories = categories
        updateCategories()
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    
    func completedTracker(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { record in
            record.id == id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(id: id, date: datePicker.date))
        }
        collectionView.reloadData()
    }
}
