//
//  LongTermSaving.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/20.
//

import RealmSwift

class LongTermSaving: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var startYearMonth: String = ""
    @objc dynamic var regularSavingAmount: Double = 0.0
    @objc dynamic var category: Category!
    let goals = List<Goal>()

    convenience init(title: String, startYearMonth: String, regularSavingAmount: Double, category: Category) {
        self.init()
        self.title = title
        self.startYearMonth = startYearMonth
        self.regularSavingAmount = regularSavingAmount
        self.category = category
    }
    
    func getSavedAmount() -> Double! {
        var savedAmount: Double = 0.0
        for goal in self.goals {
            savedAmount += goal.getTransactionsAmountSum()
        }
        return savedAmount
    }
}
