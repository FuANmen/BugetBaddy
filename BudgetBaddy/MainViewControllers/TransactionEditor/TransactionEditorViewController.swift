//
//  CreateTransactionViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/18.
//

import UIKit
protocol TransactionEditorViewDelegate: AnyObject {
    func addTransaction(transaction: Transaction)
    func updateTransaction(transaction: Transaction)
    func addCategory(category: Category)
}

class TransactionEditorViewController: UIViewController {
    weak var delegate: TransactionEditorViewDelegate?
    
    private var wallet: Wallet
    private var targetMonth: String
    private var selectedCategoryId: String
    
    private var transaction: Transaction? = nil {
        didSet {
            if transaction == nil {
                self.categoryPickerTextField.text = self.wallet.categories[0].name
                self.datePicker.date = Date()
                self.amountTextField.text = ""
            } else {
                if let category = self.wallet.categories.first(where: { $0.categoryId == transaction!.categoryId }) {
                    self.categoryPickerTextField.text = category.name
                    self.datePicker.date = transaction!.date
                    self.amountTextField.text = String(Int(transaction!.amount))
                }
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
    
    init(wallet: Wallet, targetMonth: String, transaction: Transaction? = nil) {
        self.wallet = wallet
        self.targetMonth = targetMonth
        self.transaction = transaction
        self.selectedCategoryId = transaction == nil ? wallet.categories[0].categoryId : transaction!.categoryId
        
        super.init(nibName: nil, bundle: nil)
        
        // CategoryPicker
        categoryPickerTextField.configure(wallet: wallet, targetMonth: targetMonth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
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
            let newTrans = Transaction(id: nil,
                                       date: datePicker.date,
                                       categoryId: self.selectedCategoryId,
                                       title: "",
                                       amount: Double(self.amountTextField.text!)!)
            MonthlyTransactionsDao.addTransactionToMonthlyTransactions(walletId: self.wallet.walletId, targetMonth: self.targetMonth, newTransaction: newTrans)
            self.delegate?.addTransaction(transaction: newTrans)
        } else {
            let updTrans = Transaction(id: self.transaction!.id,
                                       date: datePicker.date,
                                       categoryId: self.selectedCategoryId,
                                       title: "",
                                       amount: Double(self.amountTextField.text!)!)
            MonthlyTransactionsDao.updateTransactionInMonthlyTransactions(walletId: self.wallet.walletId, targetMonth: self.targetMonth, updatedTransaction: updTrans)
            self.delegate?.updateTransaction(transaction: updTrans)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        self.targetMonth = formatter.string(from: datePicker.date)
        categoryPickerTextField.configure(wallet: self.wallet, targetMonth: self.targetMonth)
    }
}

extension TransactionEditorViewController: UITextFieldDelegate, CategoryPickerTextFieldDelegate {
    func addCategory(category: Category) {
        if wallet.categories.firstIndex(where: { $0.name == category.name }) != nil {
            present(ShowAlerts().showErrorAlert(message:  NSLocalizedString("In_MS_Error001", comment: "")), animated: true, completion: nil)
            return
        } else {
            self.wallet.categories.append(category)
        }
        self.delegate!.addCategory(category: category)
    }
    
    func enterdCategory(category: Category) {
        self.selectedCategoryId = category.categoryId
    }
}
