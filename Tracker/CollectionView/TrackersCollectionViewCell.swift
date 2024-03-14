//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Никита on 04.03.2024.
//

import Foundation
import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completedTracker(id: UUID)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "trackersCollectionViewCell"
    
    public weak var delegate: TrackersCollectionViewCellDelegate?
    public var menuView: UIView {
        return trackerView
    }
    private var isCompletedToday: Bool = false
    private var trackerId: UUID? = nil
    private let limitNumberOfCharacters = 38
    
    private lazy var pinImageView: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "pinSquare")
        image.isHidden = false
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var trackerView: UIView = {
        let trackerView = UIView()
        trackerView.layer.cornerRadius = 16
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        return trackerView
    }()
    
    private lazy var emojiView: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        emojiView.layer.cornerRadius = 12
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        return emojiView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.clipsToBounds = true
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
    }()
    
    private lazy var trackerNameLabel: UILabel = {
        let trackerNameLabel = UILabel()
        trackerNameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        trackerNameLabel.textColor = .white
        trackerNameLabel.numberOfLines = 2
        trackerNameLabel.text = "Название трекера"
        trackerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return trackerNameLabel
    }()
    
    private lazy var resultLabel: UILabel = {
        let resultLabel = UILabel()
        resultLabel.text = "0 дней"
        resultLabel.textColor = .ypBlack
        resultLabel.font = .systemFont(ofSize: 12, weight: .medium)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        return resultLabel
    }()
    
    private lazy var checkButton: UIButton = {
        let checkButton = UIButton()
        checkButton.setImage(UIImage(named: "plus"), for: .normal)
        checkButton.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        checkButton.tintColor = .ypWhite
        checkButton.layer.cornerRadius = 17
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        return checkButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(trackerView)
        contentView.addSubview(resultLabel)
        contentView.addSubview(checkButton)
        trackerView.addSubview(emojiView)
        trackerView.addSubview(pinImageView)
        emojiView.addSubview(emojiLabel)
        trackerView.addSubview(trackerNameLabel)
        
        NSLayoutConstraint.activate([
            
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -58),
            
            pinImageView.heightAnchor.constraint(equalToConstant: 12),
            pinImageView.widthAnchor.constraint(equalToConstant: 8),
            pinImageView.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 18),
            pinImageView.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor) ,
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            trackerNameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            trackerNameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            
            checkButton.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 8),
            checkButton.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            checkButton.heightAnchor.constraint(equalToConstant: 34),
            checkButton.widthAnchor.constraint(equalToConstant: 34 ),
            
            resultLabel.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func didTapCheckButton() {
        guard let id = trackerId else {
            print("Id not set")
            return
        }
        delegate?.completedTracker(id: id)
    }
    
    func configure(
        _ id: UUID,
        name: String,
        color: UIColor,
        emoji: String,
        isCompleted: Bool,
        isEnabled: Bool,
        completedCount: Int,
        pinned: Bool
    ) {
        trackerId = id
        trackerNameLabel.text = name
        trackerView.backgroundColor = color
        checkButton.backgroundColor = color
        emojiLabel.text = emoji
        pinImageView.isHidden = !pinned
        isCompletedToday = isCompleted
        if let image = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus") {
            checkButton.setImage(image, for: .normal)
        }
        checkButton.isEnabled = isEnabled
        resultLabel.text = String.localizedStringWithFormat(NSLocalizedString("numberOfDay", comment: "Число дней"), completedCount)
    }
}
