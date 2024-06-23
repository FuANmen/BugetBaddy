//
//  CategorysSettingViewCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/23.
//

import UIKit

protocol CategorysSettingViewCellDelegate: AnyObject {
    func saveButtonTapped(in cell: CategorysSettingViewCell, name: String)
}

class CategorysSettingViewCell: UITableViewCell, UITextFieldDelegate {
    var category: Category?
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    weak var delegate: CategorysSettingViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(cancelButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(textField)
        
        textField.delegate = self
        saveButton.isHidden = true
        cancelButton.isHidden = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // UITextField
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textField.widthAnchor.constraint(equalToConstant: 200),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // 保存ボタン
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            saveButton.widthAnchor.constraint(equalToConstant: 60),
            
            // キャンセルボタン
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -4),
            cancelButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cancelButton.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func configure(with category: Category) {
        self.category = category
        textField.text = category.name
        textField.placeholder = category.name
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if saveButton.isHidden {
            showButtons()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        hideButtons()
        textField.text = category!.name
    }

    @objc func saveButtonTapped() {
        if textField.text != "" {
            delegate?.saveButtonTapped(in: self, name: textField.text!)
        } else {
            hideButtons()
            textField.text = category!.name
        }
    }
    func didSave() {
        textField.resignFirstResponder()
    }

    @objc func cancelButtonTapped() {
        hideButtons()
        textField.text = category!.name
        textField.resignFirstResponder()
    }

    func showButtons() {
        saveButton.isHidden = false
        cancelButton.isHidden = false
    }

    func hideButtons() {
        saveButton.isHidden = true
        cancelButton.isHidden = true
    }
}
