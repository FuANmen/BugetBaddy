//
//  MonthlyGoals.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/24.
//

import Foundation

class MonthlyGoals {
    var walletId: String
    var targetMonth: String
    var budget: Double
    var transferLogs: [TransferLog]
    var goals: [Goal]
    
    init(walletId: String, targetMonth: String, budget: Double, transferLogs: [TransferLog], goals: [Goal]) {
        self.walletId = walletId
        self.targetMonth = targetMonth
        self.budget = budget
        self.transferLogs = transferLogs
        self.goals = goals
    }
    
    init?(dictionary: [String: Any]) {
        guard let walletId = dictionary["walletId"] as? String,
              let targetMonth = dictionary["targetMonth"] as? String,
              let budget = dictionary["budget"] as? Double,
              let transferLogsData = dictionary["transferLogs"] as? [[String: Any]],
              let goalsData = dictionary["goals"] as? [[String: Any]] else {
            return nil
        }
        self.walletId = walletId
        self.targetMonth = targetMonth
        self.budget = budget
        
        self.transferLogs = transferLogsData.map { document in
            TransferLog(dictionary: document)!
        }
        
        self.goals = goalsData.map { document in
            Goal(dictionary: document)!
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "walletId": walletId,
            "targetMonth": targetMonth,
            "budget": budget,
            "transferLogs": transferLogs.map { $0.toDictionary() },
            "goals": goals.map { $0.toDictionary() }
        ]
    }
}

class TransferLog {
    var title: String
    var amount: Double
    
    init(title: String, amount: Double) {
        self.title = title
        self.amount = amount
    }
    
    init?(dictionary: [String: Any]) {
        guard let title = dictionary["title"] as? String,
              let amount = dictionary["amount"] as? Double else {
            return nil
        }
        self.title = title
        self.amount = amount
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "amount": amount
        ]
    }
}

class Goal {
    var categoryId: String
    var budget: Double
    
    init(categoryId: String, budget: Double, balance: Double) {
        self.categoryId = categoryId
        self.budget = budget
    }

    init?(dictionary: [String: Any]) {
        guard let categoryId = dictionary["categoryId"] as? String,
              let budget = dictionary["budget"] as? Double else {
            return nil
        }
        self.categoryId = categoryId
        self.budget = budget
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "categoryId": categoryId,
            "budget": budget
        ]
    }
}
