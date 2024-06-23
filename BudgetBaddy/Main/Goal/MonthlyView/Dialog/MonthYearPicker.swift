//
//  MonthYearPicker.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/03.
//

import Foundation
import UIKit

class MonthYearPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    var months: [String]!
    var years: [String]!

    var selectedMonthYear: String {
        let selectedYearIndex = selectedRow(inComponent: 0)
        let selectedMonthIndex = selectedRow(inComponent: 1)

        let selectedMonth = months[selectedMonthIndex]
        let selectedYear = years[selectedYearIndex]

        return "\(selectedYear)-\(selectedMonth)"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup(defaultValue: String = "2000-01") {
        self.delegate = self
        self.dataSource = self
        
        let defYear = defaultValue.prefix(4)
        let defMonth = defaultValue.suffix(2)

        let currentYear = Calendar.current.component(.year, from: Date())
        years = (currentYear - 2 ... currentYear + 2).map { "\($0)" }
        months = ["01","02","03","04","05","06","07","08","09","10","11","12",]
        
        for i in 0..<years.count {
            if years[i] == defYear {
                self.selectRow(i, inComponent: 0, animated: false)
            }
        }
        for i in 0..<months.count {
            if months[i] == defMonth {
                self.selectRow(i, inComponent: 1, animated: false)
            }
        }
    }

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 年と月の2つのコンポーネントを持つ
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else {
            return months.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(component == 0 ? years[row] : months[row])"
    }
}
