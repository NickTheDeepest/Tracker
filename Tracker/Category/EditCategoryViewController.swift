//
//  EditCategoryViewController.swift
//  Tracker
//
//  Created by Никита on 10.03.2024.
//

import Foundation
import UIKit

final class EditCategoryViewController: UIViewController {
    
    var editableCategory: TrackerCategory?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = "Редактирование категории"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .ypBlack
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.indent(size: 10)
        textField.text = editableCategory?.title
        UITextField.appearance().clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var editCategoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .ypBlack
        button.isEnabled = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(editCategoryButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    @objc func textFieldChanged() {
        if textField.text != "" {
            editCategoryButton.backgroundColor = .black
            editCategoryButton.isEnabled = true
        } else {
            editCategoryButton.backgroundColor = .gray
            editCategoryButton.isEnabled = false
        }
    }
    
    @objc func editCategoryButtonAction() {
        guard let editableCategory = editableCategory else { return }
        if let newName = textField.text {
            try? trackerCategoryStore.updateCategoryName(newName, editableCategory)
            dismiss(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        textField.becomeFirstResponder()
        addSubviews()
        setupLayout()
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(editCategoryButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            
            editCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            editCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
