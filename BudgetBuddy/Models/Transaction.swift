//
//  Transaction.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/01.
//

import Foundation
import RealmSwift

class Transaction: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var memo: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var paymentMethod: String?
    @objc dynamic var location: String?
    @objc dynamic var category: Category?

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(category: Category, amount: Double, memo: String = "", date: Date = Date(), paymentMethod: String? = nil, location: String? = nil) {
        self.init()
        self.category = category
        self.amount = amount
        self.memo = memo
        self.date = date
        self.paymentMethod = paymentMethod
        self.location = location
    }
    
    internal func getTitle() -> String {
        return self.category!.name
    }
}
