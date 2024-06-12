//
//  AlertCollectionCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/30.
//

import UIKit

protocol AlertCollectionCellDelegate: AnyObject {
    func closeButtonTapped_onAlertCell(sender: UIButton)
}

class AlertCollectionCell: UICollectionViewCell {
    weak var delegate: AlertCollectionCellDelegate?
    static let identifier = "AlertCollectionCell"
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray2
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 18
        self.backgroundColor = UIColor(red:220, green: 220, blue: 220, alpha: 0.4)
        
        self.contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 14),
            closeButton.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure() {
        
    }
    
    // MARK: - ACTION EVENT
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.delegate!.closeButtonTapped_onAlertCell(sender: sender)
    }
}
