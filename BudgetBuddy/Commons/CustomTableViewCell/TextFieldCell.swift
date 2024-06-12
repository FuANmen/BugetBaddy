//
//  TextFieldCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/13.
//

import UIKit
protocol TextFieldTableDelegate: AnyObject {
    func changedText(value: String, tag: Int)
}

class TextFieldTableCell: UITableViewCell {
    static let identifier = "TextFieldTableCell"
    weak var delegate: TextFieldTableDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.isEnabled = false
        textField.addTarget(self, action: #selector(changedText), for: .editingChanged)
        textField.addTarget(self, action: #selector(endEditText), for: .editingDidEnd)
        return textField
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
        contentView.addSubview(editButton)
        contentView.addSubview(textField)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -4),
            editButton.widthAnchor.constraint(equalToConstant: 20),
            editButton.heightAnchor.constraint(equalToConstant: 20),

            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(labelText: String, fieldValue: String, tag: Int = 0) {
        titleLabel.text = labelText
        textField.text = fieldValue
        textField.placeholder = fieldValue
        self.tag = tag
    }
    
    @objc private func editButtonTapped() {
        self.textField.isEnabled = true
        self.textField.becomeFirstResponder()
    }
    
    @objc private func changedText() {
        self.delegate!.changedText(value: self.textField.text!, tag: self.tag)
    }
    
    @objc private func endEditText() {
        if textField.text == "" {
            textField.text = textField.placeholder
        }
        self.textField.isEnabled = false
    }
}
