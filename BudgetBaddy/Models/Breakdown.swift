//
//  MonthryBreakDown.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/28.
//

import Foundation
import RealmSwift

class Breakdown: Object {
    @objc dynamic var targetMonth: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var source_pattern: String = "0" // none: "0", bankAccount: "1"
    @objc dynamic var sort_order: Int = 0
    
    convenience init(targetMonth: String, title: String, amount: Double, source_pattern: String = "0", sort_order: Int? = nil) {
        self.init()
        self.targetMonth = targetMonth
        self.title = title
        self.amount = amount
        self.source_pattern = source_pattern
        
        if sort_order == nil {
            let max: Int? = BreakdownDao().getMonthryBreakdown(targetMonth: targetMonth).max(ofProperty: "sort_order") as Int?
            self.sort_order = max ?? 0
        }
    }
}
