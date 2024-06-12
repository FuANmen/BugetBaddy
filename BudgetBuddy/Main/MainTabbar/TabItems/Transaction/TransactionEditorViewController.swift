//
//  CreateTransactionViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/18.
//

import UIKit
protocol TransactionEditorViewDelegate: AnyObject {
    func saveBtnTapped_atTransactionEditor()
}

class TransactionEditorViewController: UIViewController {
    weak var delegate: TransactionEditorViewDelegate?
    
    private var defaultCategory: Category = CategoryDao().getOrCreateOtherCategory()
    private var transaction: Transaction? = nil {
        didSet {
            if transaction == nil {
                self.categoryPickerTextField.text = self.defaultCategory.name
                self.datePicker.date = Date()
                self.amountTextField.text = ""
            } else {
                self.categoryPickerTextField.text = transaction!.category!.name
                self.datePicker.date = transaction!.date
                self.amountTextField.text = String(Int(transaction!.amount))
            }
        }
    }
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private let categoryPickerTextField: CategoryPickerTextField = {
        let textField = CategoryPickerTextField()
        textField.tranInputTarget_flg = true
        textField.placeholder = NSLocalizedString("In_Placeholder_1", comment: "")
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("In_Placeholder_2", comment: "")
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("In_SaveButton", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    internal func configure(targetMonth: String = DateFuncs().convertStringFromDate(Date(), format: "yyyy-MM"), transaction: Transaction? = nil, defaultCategory: Category? = nil) {
        // Category
        categoryPickerTextField.targetMonth = targetMonth
        categoryPickerTextField.loadCategories()
        if defaultCategory != nil {
            self.defaultCategory = defaultCategory!
        }
        // Transaction
        self.transaction = transaction
    }
    
    private func setupUI() {
        view.addSubview(datePicker)
        view.addSubview(categoryPickerTextField)
        view.addSubview(amountTextField)
        view.addSubview(saveButton)
        
        categoryPickerTextField.delegate = self
        categoryPickerTextField.myDelegate = self

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        categoryPickerTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            categoryPickerTextField.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            categoryPickerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryPickerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            amountTextField.topAnchor.constraint(equalTo: categoryPickerTextField.bottomAnchor, constant: 16),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 32),
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
        if self.transaction == nil {
            TransactionDao().addTransaction(amount: Double(self.amountTextField.text!)!
                                            , memo: ""
                                            , date: datePicker.date
                                            , paymentMethod: ""
                                            , location: ""
                                            , category: CategoryDao().getCategory(name: self.categoryPickerTextField.text!)!)
        } else {
            TransactionDao().updateTransaction(transaction: self.transaction!
                                               , amount: Double(self.amountTextField.text!)!
                                               , date: datePicker.date
                                               , paymentMethod: ""
                                               , location: "")
        }
        self.delegate?.saveBtnTapped_atTransactionEditor()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        categoryPickerTextField.targetMonth = formatter.string(from: Date())
        categoryPickerTextField.loadCategories()
    }
}

extension TransactionEditorViewController: UITextFieldDelegate, CategoryPickerTextFieldDelegate {
    func checkAddCategory(name: String) -> Bool! {
        if CategoryDao().getCategory(name: name) != nil {
            present(ShowAlerts().showErrorAlert(message:  NSLocalizedString("In_MS_Error001", comment: "")), animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func enterdCategory(category: Category) {
        
    }
}
