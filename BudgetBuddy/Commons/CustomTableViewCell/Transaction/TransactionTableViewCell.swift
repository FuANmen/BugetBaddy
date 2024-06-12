//
//  TransactionTableViewCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/06.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    static let identifier = "TransactionTableViewCell"
    static let cellHeight: CGFloat = 50
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .systemGray2
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            amountLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with transaction: Transaction, categoryName: String) {
        if categoryName == NSLocalizedString("Total", comment: "") {
            titleLabel.text = transaction.category!.name
        } else {
            titleLabel.text = DateFuncs().convertStringFromDate(transaction.date, format: "dd" + NSLocalizedString("Day", comment: ""))
        }
        amountLabel.text = formatCurrency(amount: transaction.amount)
    }
}
