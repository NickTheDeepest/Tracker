//
//  EmojiAndColorsCollectionView.swift
//  Tracker
//
//  Created by Никита on 05.03.2024.
//

import Foundation
import UIKit

final class EmojiAndColorsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "emojiAndColorsCollectionViewCell"
    
    lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = .boldSystemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
    }()
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorView)
        
        let colorViewHeight: CGFloat = 40
        let colorViewWidth: CGFloat = 40
        
        NSLayoutConstraint.activate([
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: colorViewHeight),
            colorView.widthAnchor.constraint(equalToConstant: colorViewWidth)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
