//
//  CreateEventTrackerViewController.swift
//  Tracker
//
//  Created by Никита on 05.03.2024.
//

import Foundation
import UIKit

enum Event {
    case regular
    case irregular
    
    var titleText: String {
        switch self {
        case .regular:
            return "Новая привычка"
        case .irregular:
            return "Новое нерегулярное событие"
        }
    }
    
    var editTitleText: String {
        switch self {
        case .regular:
            return "Редактирование привычки"
        case .irregular:
            return "Редактирование привычки"
        }
    }
}

protocol CreateEventViewControllerDelegate: AnyObject {
    func createTracker(
        _ tracker: Tracker,
        categoryName: String)
}

class CreateEventViewController: UIViewController {
    public weak var delegate: CreateEventViewControllerDelegate?
    
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private let event: Event
    private let nameCell = ["Категория", "Расписание"]
    private let limitNumberOfCharacters = 38
    private let colorsArray: [UIColor] = [.color1, .color2, .color3, .color4, .color5,
                                          .color6, .color7, .color8, .color9, .color10,
                                          .color11, .color12, .color13, .color14, .color15,
                                          .color16, .color17, .color18]
    private let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                           "😇", "😡", "🥶", "🤔", "🙌", "🍒",
                           "🍔", "🥦", "🏓", "🥇", "🎸", "🏝"]
    
    private var collectionViewHeader = ["Emoji", "Цвет"]
    private var numberOfCharacters = 0
    private var completedTrackers: [TrackerRecord] = []
    private var selectedEmojiCell: IndexPath? = nil
    private var selectedColorCell: IndexPath? = nil
    private var heightAnchor: NSLayoutConstraint?
    private var scheduleSubTitle: String = ""
    private var dayOfWeek: [String] = []
    private var schedule: [Weekday] = [] {
        didSet {
            updateCreateEventButton()
        }
    }
    
    private var selectedColor: UIColor? = nil {
        didSet {
            updateCreateEventButton()
        }
    }
    
    private var selectedEmoji: String = "" {
        didSet {
            updateCreateEventButton()
        }
    }
    
    var category: TrackerCategory? = nil {
        didSet {
            updateCreateEventButton()
        }
    }
    
    var editTracker: Tracker?
    var editTrackerDate: Date?
    var selectedCategory: TrackerCategory?
    var categorySubTitle: String = ""
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhite
        scrollView.frame = view.bounds
        scrollView.contentSize = contentSize
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height + 450)
    }
    
    private lazy var titleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var completedDaysBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var completedDaysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = "Дней"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = editTracker == nil ? event.titleText : event.editTitleText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        UITextField.appearance().clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: textField.frame.minX, y: textField.frame.minY, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.placeholder = "Введите название трекера"
        textField.textColor = .ypBlack
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createEventView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var forwardImage1: UIImageView = {
        let forwardImage = UIImageView()
        forwardImage.image = UIImage(named: "chevronForward")
        forwardImage.translatesAutoresizingMaskIntoConstraints = false
        return forwardImage
    }()
    
    private lazy var forwardImage2: UIImageView = {
        let forwardImage = UIImageView()
        forwardImage.image = UIImage(named: "chevronForward")
        forwardImage.translatesAutoresizingMaskIntoConstraints = false
        return forwardImage
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(categoryButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var categoryButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryButtonSubTitle: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.text = categorySubTitle
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(scheduleButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scheduleButtonTitle: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleButtonSubTitle: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.text = scheduleSubTitle
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createEventButton: UIButton = {
        let button = UIButton()
        var titleButton = editTracker == nil ? "Создать" : "Сохранить"
        button.setTitleColor(.ypWhite, for: .normal)
        button.setTitle(titleButton, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createEventButtonAction), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor.ypRed, for: UIControl.State.normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojiAndColorsCollectionViewCell.self, forCellWithReuseIdentifier: EmojiAndColorsCollectionViewCell.identifier)
        collectionView.register(EmojiAndColorsSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiAndColorsSupplementaryView.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(_ event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addSubviews()
        setupLayout()
        setupEditTracker()
        emojiAndColorCollectionView.allowsMultipleSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let indexPathEmoji = emojies.firstIndex(where: {$0 == selectedEmoji}) else { return }
        let cellEmoji = self.emojiAndColorCollectionView.cellForItem(at: IndexPath(row: indexPathEmoji, section: 0))
        cellEmoji?.backgroundColor = .backgroundColor
        selectedEmojiCell = IndexPath(row: indexPathEmoji, section: 0)
        
        guard let indexPathColor = colorsArray.firstIndex(where: {$0.hexString == selectedColor?.hexString}) else { return }
        let cellColor = self.emojiAndColorCollectionView.cellForItem(at: IndexPath(row: indexPathColor, section: 1))
        cellColor?.layer.borderWidth = 3
        cellColor?.layer.cornerRadius = 8
        cellColor?.layer.borderColor = selectedColor?.withAlphaComponent(0.3).cgColor
        selectedColorCell = IndexPath(item: indexPathColor, section: 1)
    }
    
    func setupEditTracker() {
        if let editTracker = editTracker {
            schedule = editTracker.schedule ?? []
            textField.text = editTracker.name
            selectedEmoji = editTracker.emojie ?? ""
            selectedColor = editTracker.color ?? nil
            createSchedule(schedule: schedule)
            categorySubTitle = category?.title ?? ""
            completedDaysBackgroundView.isHidden = false
            updateScheduleButton()
            updateCategoryButton()
            updateCompletedTrackers()
        }
    }
    
    private func updateCompletedTrackers() {
        if let editTracker = editTracker,
           let editTrackerDate = editTrackerDate {
            completedTrackers = trackerRecordStore.trackerRecords
            let completedCount = completedTrackers.filter({ record in
                record.id == editTracker.id
            }).count
            completedDaysLabel.text = String.localizedStringWithFormat(NSLocalizedString("numberOfDay", comment: "дней"), completedCount)
        }
    }
    
    @objc func createEventButtonAction() {
        var tracker: Tracker?
        if editTracker == nil {
            if event == .regular {
                tracker = Tracker(id: UUID(), name: textField.text ?? "", color: selectedColor, emojie: selectedEmoji, schedule: schedule, pinned: false)
            } else {
                schedule = Weekday.allCases
                tracker = Tracker(id: UUID(), name: textField.text ?? "", color: selectedColor, emojie: selectedEmoji, schedule: schedule, pinned: false)
            }
            guard let tracker = tracker else { return }
            delegate?.createTracker(tracker, categoryName: category?.title ?? "Без категории")
        } else {
            guard let editTracker = editTracker else { return }
            
            try? trackerStore.updateTracker(
                newNameTracker: textField.text ?? "",
                newEmoji: selectedEmoji,
                newColor: selectedColor?.hexString ?? "",
                newSchedule: schedule,
                categoryName: category?.title ?? "Без категории",
                editableTracker: editTracker
            )
        }
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonAction() {
        dismiss(animated: true)
    }
    
    @objc private func categoryButtonAction() {
        let categoryVC = CategoryViewController(delegate: self, selectedCategory: category)
        present(categoryVC, animated: true)
    }
    
    @objc private func scheduleButtonAction() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.schedule = schedule
        present(scheduleVC, animated: true)
    }
    
    func updateCreateEventButton() {
        createEventButton.isEnabled = textField.text?.isEmpty == false && selectedColor != nil && !selectedEmoji.isEmpty
        if event == .regular {
            createEventButton.isEnabled = createEventButton.isEnabled && !schedule.isEmpty
        }
        
        if createEventButton.isEnabled {
            createEventButton.backgroundColor = .ypBlack
        } else {
            createEventButton.backgroundColor = .gray
        }
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        view.addSubview(titleBackgroundView)
        titleBackgroundView.addSubview(label)
        scrollView.addSubview(completedDaysBackgroundView)
        completedDaysBackgroundView.addSubview(completedDaysLabel)
        scrollView.addSubview(textField)
        scrollView.addSubview(errorLabel)
        scrollView.addSubview(createEventView)
        createEventView.addSubview(categoryButton)
        categoryButton.addSubview(forwardImage1)
        if event == .regular {
            createEventView.addSubview(separatorView)
            createEventView.addSubview(scheduleButton)
            scheduleButton.addSubview(forwardImage2)
        }
        updateScheduleButton()
        updateCategoryButton()
        scrollView.addSubview(emojiAndColorCollectionView)
        view.addSubview(buttonBackgroundView)
        buttonBackgroundView.addSubview(createEventButton)
        buttonBackgroundView.addSubview(cancelButton)
    }
    
    private func setupLayout() {
        let createEventViewHeight: CGFloat = event == .regular ? 150 : 75
        let textFieldTop: CGFloat = editTracker == nil ? 24 : 102
        heightAnchor = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        var constraints = [
            titleBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            
            label.centerXAnchor.constraint(equalTo: titleBackgroundView.centerXAnchor),
            label.topAnchor.constraint(equalTo: titleBackgroundView.topAnchor, constant: 27),
            label.heightAnchor.constraint(equalToConstant: 25),
            label.widthAnchor.constraint(equalToConstant: 250),
            
            scrollView.topAnchor.constraint(equalTo: titleBackgroundView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonBackgroundView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            completedDaysBackgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            completedDaysBackgroundView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            completedDaysBackgroundView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            completedDaysBackgroundView.heightAnchor.constraint(equalToConstant: 38),
            
            completedDaysLabel.widthAnchor.constraint(equalToConstant: 120),
            completedDaysLabel.centerXAnchor.constraint(equalTo: completedDaysBackgroundView.centerXAnchor),
            completedDaysLabel.heightAnchor.constraint(equalToConstant: 38),
            
            textField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: textFieldTop),
            textField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0),
            errorLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            heightAnchor,
            
            createEventView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            createEventView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            createEventView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            createEventView.heightAnchor.constraint(equalToConstant: createEventViewHeight),
            
            categoryButton.topAnchor.constraint(equalTo: createEventView.topAnchor),
            categoryButton.bottomAnchor.constraint(equalTo:  self.event == .regular ? separatorView.topAnchor : createEventView.bottomAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: createEventView.trailingAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: createEventView.leadingAnchor),
            
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: createEventView.bottomAnchor, constant: 22),
            emojiAndColorCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            emojiAndColorCollectionView.widthAnchor.constraint(equalToConstant: scrollView.bounds.width - 32),
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 450),
            
            buttonBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonBackgroundView.heightAnchor.constraint(equalToConstant: 80),
            
            forwardImage1.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -24),
            forwardImage1.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            
            cancelButton.leadingAnchor.constraint(equalTo: buttonBackgroundView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: buttonBackgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createEventButton.trailingAnchor.constraint(equalTo: buttonBackgroundView.trailingAnchor, constant: -20),
            createEventButton.bottomAnchor.constraint(equalTo: buttonBackgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createEventButton.widthAnchor.constraint(equalToConstant: 161),
            createEventButton.heightAnchor.constraint(equalToConstant: 60)
        ].compactMap{ $0 }
        
        if event == .regular {
            constraints += [
                separatorView.centerYAnchor.constraint(equalTo: createEventView.centerYAnchor),
                separatorView.trailingAnchor.constraint(equalTo: createEventView.trailingAnchor, constant: -10),
                separatorView.leadingAnchor.constraint(equalTo: createEventView.leadingAnchor, constant: 10),
                separatorView.heightAnchor.constraint(equalToConstant: 0.5),
                
                scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
                scheduleButton.bottomAnchor.constraint(equalTo: createEventView.bottomAnchor),
                scheduleButton.trailingAnchor.constraint(equalTo: createEventView.trailingAnchor),
                scheduleButton.leadingAnchor.constraint(equalTo: createEventView.leadingAnchor),
                forwardImage2.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -24),
                forwardImage2.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func updateScheduleButton() {
        if scheduleSubTitle.isEmpty {
            scheduleButton.addSubview(scheduleButtonTitle)
            NSLayoutConstraint.activate([
                scheduleButtonTitle.topAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: 27),
                scheduleButtonTitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16)
            ])
            scheduleButtonSubTitle.isHidden = true
        } else {
            scheduleButton.addSubview(scheduleButtonTitle)
            scheduleButton.addSubview(scheduleButtonSubTitle)
            NSLayoutConstraint.activate([
                scheduleButtonTitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                scheduleButtonTitle.topAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: 15),
                scheduleButtonSubTitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                scheduleButtonSubTitle.bottomAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -13)
            ])
            scheduleButtonSubTitle.text = scheduleSubTitle
            scheduleButtonSubTitle.isHidden = false
        }
    }
    
    func updateCategoryButton() {
        if categorySubTitle.isEmpty {
            categoryButton.addSubview(categoryButtonTitle)
            NSLayoutConstraint.activate([
                categoryButtonTitle.topAnchor.constraint(equalTo: categoryButton.topAnchor, constant: 27),
                categoryButtonTitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16)])
        } else {
            categoryButton.addSubview(categoryButtonTitle)
            categoryButton.addSubview(categoryButtonSubTitle)
            NSLayoutConstraint.activate([
                categoryButtonTitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                categoryButtonTitle.topAnchor.constraint(equalTo: categoryButton.topAnchor, constant: 15),
                categoryButtonSubTitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                categoryButtonSubTitle.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: -13)])
            categoryButtonSubTitle.text = categorySubTitle
        }
    }
    
    @objc func textFieldChanged() {
        updateCreateEventButton()
        guard let number = textField.text?.count else { return }
        numberOfCharacters = number
        if numberOfCharacters < limitNumberOfCharacters {
            errorLabel.text = ""
            heightAnchor?.constant = 0
        } else {
            errorLabel.text = "Ограничение 38 символов"
            heightAnchor?.constant = 32
        }
    }
}

extension CreateEventViewController: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let maxLenght = limitNumberOfCharacters
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLenght
    }
}

extension CreateEventViewController: ScheduleViewControllerDelegate {
    
    func createSchedule(schedule: [Weekday]) {
        self.schedule = schedule
        let scheduleString = schedule.map { $0.shortName }.joined(separator: ", ")
        scheduleSubTitle = scheduleString == "Пн, Вт, Ср, Чт, Пт, Сб, Вс" ? "Каждый день" : scheduleString
        updateScheduleButton()
    }
}

extension CreateEventViewController: CategoryViewModelDelegate {
    func createCategory(category: TrackerCategory) {
        self.category = category
        let categoryString = category.title
        categorySubTitle = categoryString
        updateCategoryButton()
    }
}

extension CreateEventViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            var returnValue = Int()
            if section == 0 {
                returnValue = emojies.count
            } else if section == 1 {
                returnValue = colorsArray.count
            }
            return returnValue
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let section = indexPath.section
            
            guard let cell = emojiAndColorCollectionView.dequeueReusableCell(withReuseIdentifier: "emojiAndColorsCollectionViewCell", for: indexPath) as? EmojiAndColorsCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.layer.cornerRadius = 16
            
            if section == 0 {
                cell.emojiLabel.text = emojies[indexPath.row]
            } else if section == 1 {
                cell.colorView.backgroundColor = colorsArray[indexPath.row]
                cell.colorView.layer.cornerRadius = 8
            }
            return cell
        }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
}

extension CreateEventViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            let section = indexPath.section
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorsCollectionViewCell
            if section == 0 {
                if let selectedEmojiCell {
                    collectionView.deselectItem(at: selectedEmojiCell, animated: true)
                    collectionView.cellForItem(at: selectedEmojiCell)?.backgroundColor = .white
                }
                cell?.backgroundColor = .backgroundColor
                selectedEmoji = cell?.emojiLabel.text ?? ""
                selectedEmojiCell = indexPath
            } else if section == 1 {
                if let selectedColorCell {
                    collectionView.deselectItem(at: selectedColorCell, animated: true)
                    collectionView.cellForItem(at: selectedColorCell)?.layer.borderWidth = 0
                }
                cell?.layer.borderWidth = 3
                cell?.layer.cornerRadius = 8
                cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
                selectedColor = cell?.colorView.backgroundColor ?? nil
                selectedColorCell = indexPath
            }
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorsCollectionViewCell
            collectionView.deselectItem(at: indexPath, animated: true)
            cell?.backgroundColor = .white
            cell?.layer.borderWidth = 0
            if indexPath.section == 0 {
                selectedEmoji = ""
                selectedEmojiCell = nil
            } else {
                selectedColor = nil
                selectedColorCell = nil
            }
        }
}

extension CreateEventViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 52)
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
        return 0
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
        
        guard let view = emojiAndColorCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? EmojiAndColorsSupplementaryView else { return UICollectionReusableView() }
        let section = indexPath.section
        if section == 0 {
            view.titleLabel.text = collectionViewHeader[0]
        } else if section == 1 {
            view.titleLabel.text = collectionViewHeader[1]
        }
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension CreateEventViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        completedTrackers = trackerRecordStore.trackerRecords
    }
}

