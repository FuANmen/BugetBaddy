//
//  TransferLog.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/28.
//

import RealmSwift

class TransferLog: Object {
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var title: String = ""
    @objc dynamic var created_on: Date? = nil
    let source = LinkingObjects(fromType: Goal.self, property: "transLogsAsSour")
    let destination = LinkingObjects(fromType: Goal.self, property: "transLogsAsDest")
    
    convenience init(amount: Double = 0.0, title: String) {
        self.init()
        self.amount = amount
        self.title = title
    }
}
