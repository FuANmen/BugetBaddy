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
    func checkAddCategory(name: String) -> Bool!
    func enterdCategory(category: Category)
}

class CategoryPickerTextField: UITextField {
    weak var myDelegate: CategoryPickerTextFieldDelegate?

    private var categoryPicker: UIPickerView!
    private var toolbar: UIToolbar!

    private var categories: [Category] = []
    private let categoryDao = CategoryDao()
    
    var tranInputTarget_flg: Bool = false
    var targetMonth: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
        loadCategories()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPicker()
        loadCategories()
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

    private func selectInitialCategory() {
        // カテゴリが存在する場合、最初のカテゴリを選択する
        if self.text == "" {
            if let initialCategory = categories.first ,let rowIndex = categories.index(of: initialCategory) {
                categoryPicker.selectRow(rowIndex, inComponent: 0, animated: false)
                self.text = initialCategory.name
            }
        }
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
        let selectedCategory = categories[selectedRow]
        
        self.text = selectedCategory.name
        myDelegate?.enterdCategory(category: selectedCategory)
        
        self.resignFirstResponder()
    }

    public func loadCategories() {
        self.categories = []
        // RealmからCategoryデータを取得
        self.categories.append(categoryDao.getOrCreateOtherCategory())
        GoalDao().getInExGoals(targetMonth: self.targetMonth).forEach { goal in
            self.categories.append(goal.category!)
        }
        categoryPicker.reloadAllComponents()
        selectInitialCategory()
    }

    private func addNewCategory(name: String) {
        if myDelegate!.checkAddCategory(name: name) {
            categoryDao.addCategory(name: name, category_type_div: 0)
            loadCategories()
            // データを再読み込み
            categoryPicker.reloadAllComponents()
            // 追加したカテゴリの行を選択
            let rowIndex = categories.count
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
        return categories.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
}
