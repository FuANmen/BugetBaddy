//
//  UserSetTransferLog.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/11.
//
import RealmSwift

class UserSetTransferLog: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var amount: Double = 0.0
    
    convenience init(title: String, amount: Double) {
        self.init()
        self.title = title
        self.amount = amount
    }
}
