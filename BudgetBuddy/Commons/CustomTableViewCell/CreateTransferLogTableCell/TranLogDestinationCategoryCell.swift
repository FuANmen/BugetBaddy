//
//  TranLogSourceGoalCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/13.
//

import UIKit

class TranLogDestinationCategoryCell: UITableViewCell {
    static let identifier = "TranLogSourceCategoryCell"
    static let cellHeight: CGFloat = 65
    
    let iconImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(iconImage)
        contentView.addSubview(infoLabel)
        contentView.addSubview(titleLabel)

        iconImage.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            iconImage.heightAnchor.constraint(equalToConstant: 24),
            iconImage.widthAnchor.constraint(equalToConstant: 24),
            
            infoLabel.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 4),
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 18)
        ])
    }

    func configure(category: Category) {
        titleLabel.text = category.name
    }
}
