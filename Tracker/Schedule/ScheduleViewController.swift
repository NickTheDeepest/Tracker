//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Никита on 05.03.2024.
//

import Foundation
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func createSchedule(schedule: [Weekday])
}

class ScheduleViewController: UIViewController {
    
    public weak var delegate: ScheduleViewControllerDelegate?
    public var schedule: [Weekday] = []
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(enterButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        var width = view.frame.width - 16 * 2
        var height = 7 * 75
        tableView.register(WeekdayTableViewCell.self, forCellReuseIdentifier: WeekdayTableViewCell.identifier)
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .gray
        tableView.backgroundView = nil
        tableView.backgroundColor = .backgroundColor
        tableView.frame = CGRect(x: 16, y: 0, width: Int(width), height: 525)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.frame = view.bounds
        scrollView.contentSize = contentSize
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupLayout()
    }
    
    private func addSubviews() {
        view.addSubview(label)
        view.addSubview(scrollView)
        scrollView.addSubview(tableView)
        scrollView.addSubview(buttonBackgroundView)
        buttonBackgroundView.addSubview(enterButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            enterButton.bottomAnchor.constraint(equalTo: buttonBackgroundView.bottomAnchor, constant: -50),
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            enterButton.heightAnchor.constraint(equalToConstant: 60),
            
            scrollView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            buttonBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonBackgroundView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc
    private func enterButtonAction() {
        delegate?.createSchedule(schedule: schedule)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let weekdayCell = tableView.dequeueReusableCell(withIdentifier: WeekdayTableViewCell.identifier) as? WeekdayTableViewCell else {
            return UITableViewCell()
        }
        weekdayCell.delegate = self
        weekdayCell.selectionStyle = .none
        weekdayCell.label.text = Weekday.allCases[indexPath.row].rawValue
        weekdayCell.weekday = Weekday.allCases[indexPath.row]
        if indexPath.row == 6 {
            weekdayCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            weekdayCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return weekdayCell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ScheduleViewController: WeekdayTableViewCellDelegate {
    
    func stateChanged(for day: Weekday, isOn: Bool) {
        if isOn {
            schedule.append(day)
        } else {
            if let index = schedule.firstIndex(of: day) {
                schedule.remove(at: index)
            }
        }
    }
}
