//
//  MonthlyDefaultManagementAmountViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/23.
//
//
//  InputViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/01.
//

import UIKit

class MonthlyDefaultManagementAmountViewController: UIViewController, UITextFieldDelegate {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("SeMo_Title", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("50,000", comment: "")
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("SeMo_SaveButton", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        amountTextField.text = UserDefaults.standard.value(forKey: "MonthlyDefaultManagementAmount") as? String
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(amountTextField)
        view.addSubview(saveButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            amountTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            saveButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // キーボードを閉じるためのジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - ActionEvents
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
        UserDefaults.standard.set(amountTextField.text, forKey: "MonthlyDefaultManagementAmount")
        
        view.endEditing(true)
        
        let alertController = UIAlertController(title: NSLocalizedString("Se_Success", comment: ""), message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

