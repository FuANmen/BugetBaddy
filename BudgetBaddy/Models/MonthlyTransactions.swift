//
//  MonthlyTransactions.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/24.
//

import Foundation

class MonthlyTransactions {
    var walletId: String
    var targetMonth: String
    var transactions: [Transaction]
    
    init (walletId: String, targetMonth: String, transactions: [Transaction]) {
        self.walletId = walletId
        self.targetMonth = targetMonth
        self.transactions = transactions
    }
    
    init?(dictionary: [String: Any]) {
        guard let walletId = dictionary["walletId"] as? String,
              let targetMonth = dictionary["targetMonth"] as? String,
              let transactionsData = dictionary["transactions"] as? [[String: Any]] else {
            return nil
        }
        self.walletId = walletId
        self.targetMonth = targetMonth
        self.transactions = transactionsData.map { document in
            Transaction(dictionary: document)!
        }
    }
}

class Transaction {
    var date: Date
    var categoryId: String
    var title: String
    var amount: Double
    
    init(date: Date, categoryId: String, title: String, amount: Double) {
        self.date = date
        self.categoryId = categoryId
        self.title = title
        self.amount = amount
    }
    
    init?(dictionary: [String: Any]) {
        guard let date = dictionary["date"] as? Date,
              let categoryId = dictionary["categoryId"] as? String,
              let title = dictionary["title"] as? String,
              let amount = dictionary["amount"] as? Double else {
            return nil
        }
        self.date = date
        self.categoryId = categoryId
        self.title = title
        self.amount = amount
    }
}
