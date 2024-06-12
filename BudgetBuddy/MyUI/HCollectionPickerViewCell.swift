//
//  HCollectionPickerViewCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/01/20.
//
import UIKit

class HCollectionPickerViewCell: UICollectionViewCell {
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
    }
    
    private func configureSubviews() {
        addSubview(mainLabel)
        addSubview(subLabel)
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: topAnchor),
//            label.leadingAnchor.constraint(equalTo: leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            mainLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            subLabel.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor, constant: 0),
            subLabel.bottomAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: -2)
        ])
    }
    
    func configure(with text: String, isSelected: Bool?) {
        mainLabel.text = text
        
        if isSelected == nil {
            backgroundColor = .clear
            mainLabel.text = ""
            subLabel.text = ""
        } else {
            if isSelected! {
                mainLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold)
                mainLabel.textColor = .black
                mainLabel.alpha = 1.0
                
                subLabel.text = NSLocalizedString("Month", comment: "")
            } else {
                mainLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
                mainLabel.textColor = .systemGray3
                mainLabel.alpha = 0.5
                
                subLabel.text = ""
            }
        }
    }
}
