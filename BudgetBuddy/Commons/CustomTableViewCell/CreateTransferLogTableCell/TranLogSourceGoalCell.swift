//
//  TranLogDestinationGoalCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/13.
//

import UIKit

class TranLogSourceGoalCell: UITableViewCell {
    static let identifier = "TranLogDestinationGoalCell"
    static let cellHeight: CGFloat = 80
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .systemGray2
        return label
    }()
    
    let icon: UIImageView = {
        let image = UIImageView()
        image.tintColor = .systemBlue
        image.contentMode = .scaleAspectFill
        return image
    }()

    let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("AdGo_CellLabel_004", comment: "")
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.textColor = .systemGray2
        return label
    }()
    
    let balanceValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .systemGray2
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
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(balanceValue)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceValue.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            balanceLabel.centerYAnchor.constraint(equalTo: balanceValue.centerYAnchor),
            balanceLabel.trailingAnchor.constraint(equalTo: balanceValue.leadingAnchor, constant: -18),

            balanceValue.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            balanceValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }

    func configure(goal: Goal) {
        titleLabel.text = goal.category!.name
        balanceValue.text = formatCurrency(amount: goal.getBalance())!
    }
}
