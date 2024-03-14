//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Никита on 26.02.2024.
//

import Foundation
import UIKit

protocol StatisticsUpdateDelegate: AnyObject {
    func updateStatistics()
}

class TrackersViewController: UIViewController, StatisticsUpdateDelegate {
    func updateStatistics() {
        return
    }

    private let analytics = Analytics()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var newCategories: [TrackerCategory] = []
    private var pinnedTrackers: [Tracker] = []
    private var currentDate: Int?
    private var widthAnchor: NSLayoutConstraint?
    private var selectedFilter: Filter?
    private var searchText: String = ""
    private let titleTrackers = NSLocalizedString("trackersTitle", comment: "Title Trackers")
    private let filtersButtonTitle = NSLocalizedString("filters", comment: "Title Trackers")
    private let stubTitle = NSLocalizedString("stubTitle", comment: "stubTitle")
    private let nothingFound = NSLocalizedString("nothingFound", comment: "nothingFound")
    private let search = NSLocalizedString("search", comment: "search")
    private let cancel = NSLocalizedString("cancel", comment: "cancel")

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "1")
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = .ypBlack
        textLabel.text = stubTitle
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.layer.cornerRadius = 8
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.layer.masksToBounds = true
        return datePicker
    }()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter
    }()

    private lazy var searchTextField: UITextField = {
        let searchTextField = UITextField()
        searchTextField.placeholder = search
        searchTextField.textColor = .ypBlack
        searchTextField.font = .systemFont(ofSize: 17)
        searchTextField.backgroundColor = .backgroundColor
        searchTextField.layer.cornerRadius = 10
        searchTextField.leftView = UIView(frame: CGRect(x: searchTextField.frame.minX, y: searchTextField.frame.minY, width: 30, height: searchTextField.frame.height))
        searchTextField.leftViewMode = .always
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return searchTextField
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersSupplementaryView.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        return collectionView
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(filtersButtonTitle, for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loupeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "loupe")
        return imageView
    }()
    
    private lazy var cancelEditingButton: UIButton = {
        let button = UIButton()
        button.setTitle(cancel, for: .normal)
        button.setTitleColor(.ypBlue, for: .normal)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(cancelEditingButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        currentDate = Calendar.current.dateComponents([.weekday], from: Date()).weekday
        setupNavigationBar()
        updateCategories()
        completedTrackers = trackerRecordStore.trackerRecords
        view.addSubview(imageView)
        view.addSubview(textLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
        view.addSubview(cancelEditingButton)
        searchTextField.addSubview(loupeImageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 400),

            textLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: cancelEditingButton.leadingAnchor, constant: -5),
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),

            datePicker.widthAnchor.constraint(equalToConstant: 100),

            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            
            loupeImageView.heightAnchor.constraint(equalToConstant: 16),
            loupeImageView.widthAnchor.constraint(equalToConstant: 16),
            loupeImageView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor, constant: 8),
            loupeImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            
            cancelEditingButton.centerXAnchor.constraint(equalTo: searchTextField.centerXAnchor),
            cancelEditingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cancelEditingButton.widthAnchor.constraint(equalToConstant: 0),
            cancelEditingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
        trackerCategoryStore.delegate = self
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        analytics.openScreenReport(screen: .main)
    }

    override func viewDidDisappear(_ animated: Bool) {
        analytics.closeScreenReport(screen: .main)
    }

    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            title = titleTrackers
            let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTracker))
            leftButton.tintColor = .ypBlack
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
            var pinnedTrackers: [Tracker] = []
        newCategories = trackerCategoryStore.trackerCategories
            for category in newCategories {
                var newTrackers: [Tracker] = []
                for tracker in category.visibleTrackers(filterString: searchText, pin: nil) {
                    guard let schedule = tracker.schedule else { return }
                    let scheduleInts = schedule.map { $0.numberOfDay }
                    if let day = currentDate, scheduleInts.contains(day) {
                        if selectedFilter == .completed {
                            if !completedTrackers.contains(where: { record in
                                record.id == tracker.id &&
                                record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                            }) {
                                continue
                            }
                        }
                        if selectedFilter == .uncompleted {
                            if completedTrackers.contains(where: { record in
                                record.id == tracker.id &&
                                record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                            }) {
                                continue
                            }
                        }
                        if tracker.pinned == true {
                            pinnedTrackers.append(tracker)
                        } else {
    
                            newTrackers.append(tracker)
                        }
                    }
                    if newTrackers.count > 0 {
                        let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                        freshCategories.append(newCategory)
                    }
                }
            }
            newCategories = freshCategories
            self.pinnedTrackers = pinnedTrackers
            collectionView.reloadData()
        }
    
    private func actionSheet(trackerToDelete: Tracker) {
        let alert = UIAlertController(title: "Уверены, что хотите удалить трекер?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить",
                                      style: .destructive) { [weak self] _ in
            self?.deleteTracker(trackerToDelete)
        })
        alert.addAction(UIAlertAction(title: "Отменить",
                                      style: .cancel) { _ in
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteTracker(_ tracker: Tracker) {
        try? self.trackerStore.deleteTracker(tracker)
        trackerRecordStore.refresh()
        updateStatistics()
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
        
        do {
            try trackerRecordStore.deleteRecords(forTrackerWithID: tracker.id)
        } catch {
            print("Ошибка при удалении записей: \(error)")
        }
        updateStatistics()
    }
    
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let tracker: Tracker
        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = newCategories[indexPath.section - 1].visibleTrackers(filterString: searchText, pin: false)[indexPath.row]
        }
        let pinTitle = tracker.pinned == true ? "Открепить" : "Закрепить"
        let pin = UIAction(title: pinTitle, image: nil) { [weak self] action in
            try? self?.trackerStore.togglePinTracker(tracker)
        }
        let rename = UIAction(title: "Редактировать", image: nil) { [weak self] action in
            self?.analytics.editTrackReport()

            let editTrackerVC = CreateEventViewController(.regular)
            editTrackerVC.editTracker = tracker
            editTrackerVC.editTrackerDate = self?.datePicker.date ?? Date()
            editTrackerVC.category = tracker.category
            self?.present(editTrackerVC, animated: true)
        }
        let delete = UIAction(title: "Удалить", image: nil, attributes: .destructive) { [weak self] action in
            self?.actionSheet(trackerToDelete: tracker)
            self?.analytics.deleteTrackReport()

        }
        return UIMenu(children: [pin, rename, delete])
    }


    @objc func dateChanged(_ sender: UIDatePicker) {
        let comp = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = comp.weekday {
            currentDate = day
            updateCategories()
        }
    }

    @objc func newTracker() {
        analytics.addTrackReport()
        let trackersViewController = CreateTrackerViewController()
        trackersViewController.delegate = self
        present(trackersViewController, animated: true)
    }
    
    @objc private func filtersButtonAction() {
        analytics.addFilterReport()
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        filtersVC.selectedFilter = selectedFilter
        present(filtersVC, animated: true)
    }
    
    @objc func textFieldChanged() {
        searchText = searchTextField.text ?? ""
        imageView.image = searchText.isEmpty ? UIImage(named: "1") : UIImage(named: "notFound")
        textLabel.text = searchText.isEmpty ? stubTitle : nothingFound
        updateCategories()
    }
    
    @objc private func cancelEditingButtonAction() {
        searchTextField.text = ""
        searchText = ""
        updateCategories()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = newCategories.count
        collectionView.isHidden = count == 0 && pinnedTrackers.count == 0
        filtersButton.isHidden = collectionView.isHidden && selectedFilter == nil
        return count + 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if section == 0 {
            return pinnedTrackers.count
        } else {
            return newCategories[section - 1].visibleTrackers(filterString: searchText, pin: false).count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else {
            return UICollectionViewCell() }
        cell.delegate = self
        let tracker: Tracker
        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = newCategories[indexPath.section - 1].visibleTrackers(filterString: searchText, pin: false)[indexPath.row]
        }
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
            color: tracker.color ?? .ypBlue,
            emoji: tracker.emojie ?? "",
            isCompleted: isCompleted,
            isEnabled: isEnabled,
            completedCount: completedCount,
            pinned: tracker.pinned ?? false
        )
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (self.collectionView.bounds.width - 7) / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 7
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
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
        if indexPath.section == 0 {
            view.titleLabel.text = "Закрепленные"
        } else {
            view.titleLabel.text = newCategories[indexPath.section - 1].title
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 && pinnedTrackers.count == 0 {
            return .zero
        }
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    
    func createTracker(
        _ tracker: Tracker,
        categoryName: String) {
            var categoryToUpdate: TrackerCategory? = nil
            let categories: [TrackerCategory] = trackerCategoryStore.trackerCategories
            
            for i in 0..<categories.count {
                if categories[i].title == categoryName {
                    categoryToUpdate = categories[i]
                }
            }
            if let categoryToUpdate {
                try? trackerCategoryStore.addTracker(tracker, to: categoryToUpdate)
            } else {
                let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
                let categoryToUpdate = newCategory
                    try? trackerCategoryStore.addNewTrackerCategory(categoryToUpdate)
            }
            dismiss(animated: true)
        }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    
    func completedTracker(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { record in
            record.id == id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.deleteTrackerRecord(with: id, date: datePicker.date)
        } else {
            completedTrackers.append(TrackerRecord(id: id, date: datePicker.date))
            try? trackerRecordStore.addNewTrackerRecord(TrackerRecord(id: id, date: datePicker.date))
        }
        updateCategories()
        trackerRecordStore.refresh()
    }
}


extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        updateCategories()
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        updateCategories()
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let identifier = "\(indexPath.row):\(indexPath.section)" as NSString
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) {
            suggestedActions in
            return self.makeContextMenu(indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        analytics.clickRecordTrackReport()
        print("tap")
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else { return nil }
        let components = identifier.components(separatedBy: ":")
        print(identifier)
        guard let rowString = components.first,
              let sectionString = components.last,
              let row = Int(rowString),
              let section = Int(sectionString) else { return nil }
        let indexPath = IndexPath(row: row, section: section)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else { return nil }
        
        return UITargetedPreview(view: cell.menuView)
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func filterSelected(filter: Filter) {
        selectedFilter = filter
        searchText = ""
        switch filter {
            case .all:
                updateCategories()
            case .today:
                datePicker.date = Date()
                dateChanged(datePicker)
                updateCategories()
            case .completed:
                updateCategories()
            case .uncompleted:
                updateCategories()
        }
    }
}


