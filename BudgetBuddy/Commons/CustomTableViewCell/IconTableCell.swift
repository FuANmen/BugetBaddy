//
//  IconTableCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/19.
//

import UIKit

class IconTableCell: UITableViewCell {
    static let identifier = "IconTableCell"
    
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.tintColor = .systemGray4
        return icon
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.font = UIFont.systemFont(ofSize: 20)
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

        icon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            icon.heightAnchor.constraint(equalToConstant: 30),
            icon.widthAnchor.constraint(equalToConstant: 30),

            titleLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }

    func configure(image: UIImage, title: String, tag: Int = 1) {
        icon.setSymbolImage(image, contentTransition: .automatic)
        titleLabel.text = title
        self.tag = tag
    }
}
