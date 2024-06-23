//
//  TransactionTableViewCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/06.
//

import UIKit
protocol SwitchTableCellDelegate: AnyObject {
    func changedSwitch(value: Bool, tag: Int)
}

class SwitchTableCell: UITableViewCell {
    static let identifier = "SwitchTableViewCell"
    weak var delegate: SwitchTableCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    let uiSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.addTarget(self, action: #selector(changedSwitch), for: .valueChanged)
        return uiSwitch
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
        contentView.addSubview(uiSwitch)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            uiSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            uiSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(labelText: String, defSwitchState: Bool, tag: Int = 1) {
        titleLabel.text = labelText
        uiSwitch.isOn = defSwitchState
        self.tag = tag
    }
    
    @objc private func changedSwitch() {
        self.delegate!.changedSwitch(value: self.uiSwitch.isOn, tag: self.tag)
    }
}
