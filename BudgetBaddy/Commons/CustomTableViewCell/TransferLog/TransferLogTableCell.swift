//
//  GoalOfTransferLogCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/24.
//

import UIKit

class TransferLogTableCell: UITableViewCell {
    static let identifier = "TransferLogTableCell"
    static let cellHeight: CGFloat = 40.0
    
    private var transferLog: TransferLog? = nil
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customDarkGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()

    let amountValue: UILabel = {
        let label = UILabel()
        label.textColor = .customDarkGray
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
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
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountValue)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        amountValue.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            amountValue.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            amountValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(transferLog: TransferLog) {
        self.transferLog = transferLog
        dateLabel.text = DateFuncs().convertStringFromDate(transferLog.created_on!, format: "MM/dd") 
        amountValue.text = formatCurrency(amount: transferLog.amount)
    }
}
