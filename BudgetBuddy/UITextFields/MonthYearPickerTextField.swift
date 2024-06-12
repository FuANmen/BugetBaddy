//
//  MonthYearPickerTextField.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/03.
//

import Foundation
import UIKit

class MonthYearPickerTextField: UITextField {

    var monthYearPicker: MonthYearPicker!
    var toolbar: UIToolbar!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPicker()
    }

    func setupPicker() {
        monthYearPicker = MonthYearPicker()
        self.inputView = monthYearPicker

        // Add toolbar
        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .black
        toolbar.sizeToFit()

        // Add a done button to the toolbar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([spaceButton, doneButton], animated: false)

        // Set the toolbar as the input accessory view
        self.inputAccessoryView = toolbar
    }

    @objc func doneButtonTapped() {
        // 選択された年月をUITextFieldに設定
        self.text = monthYearPicker.selectedMonthYear
        self.resignFirstResponder()
    }
}
