//
//  CategoryPickerTextField.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/03.
//
import Foundation
import UIKit
import RealmSwift


protocol CategoryPickerTextFieldDelegate: AnyObject {
    func addCategory(category: Category)
    func enterdCategory(category: Category)
}

class CategoryPickerTextField: UITextField {
    weak var myDelegate: CategoryPickerTextFieldDelegate?

    private var categoryPicker: UIPickerView!
    private var toolbar: UIToolbar!

    private var wallet: Wallet? = nil
    private var targetMonth: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    internal func configure(wallet: Wallet, targetMonth: String) {
        self.wallet = wallet
        self.targetMonth = targetMonth
        categoryPicker.reloadAllComponents()
    }
    
    private func setupPicker() {
        categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        self.inputView = categoryPicker

        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .black
        toolbar.sizeToFit()

        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([addButton, spaceButton, doneButton], animated: false)
        self.inputAccessoryView = toolbar
    }

    @objc private func addButtonTapped() {
        // 新しいカテゴリを追加するためのダイアログを表示
        guard let currentViewController = findTopViewController() else { return }

        let alertController = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Category Name"
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let categoryName = alertController.textFields?.first?.text else { return }
            self?.addNewCategory(name: categoryName)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        currentViewController.present(alertController, animated: true, completion: nil)
    }

    private func findTopViewController() -> UIViewController? {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController

        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }

        return topViewController
    }

    @objc private func doneButtonTapped() {
        let selectedRow = categoryPicker.selectedRow(inComponent: 0)
        let selectedCategory = self.wallet!.categories[selectedRow]
        
        self.text = selectedCategory.name
        myDelegate?.enterdCategory(category: selectedCategory)
        
        self.resignFirstResponder()
    }

    private func addNewCategory(name: String) {
        let newCategory = Category(categoryId: nil, name: name)
        myDelegate!.addCategory(category: newCategory)
        
        if self.wallet!.categories.firstIndex(where: { $0.name == name }) == nil {
            WalletsDao.addCategoryToWallet(walletId: self.wallet!.walletId, newCategory: newCategory)
            self.wallet!.categories.append(newCategory)
            // データを再読み込み
            categoryPicker.reloadAllComponents()
            // 追加したカテゴリの行を選択
            let rowIndex = self.wallet!.categories.count
            categoryPicker.selectRow(rowIndex, inComponent: 0, animated: false)
            self.text = name
        }
        self.resignFirstResponder()
    }
}

extension CategoryPickerTextField: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.wallet?.categories.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.wallet?.categories[row].name ?? ""
    }
}
