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
    var budgetBreakdowns: [BudgetBreakdown]
    var goals: [Goal]
    
    init(walletId: String, targetMonth: String, budgetBreakdowns: [BudgetBreakdown], goals: [Goal]) {
        self.walletId = walletId
        self.targetMonth = targetMonth
        self.budgetBreakdowns = budgetBreakdowns
        self.goals = goals
    }
    
    init?(dictionary: [String: Any]) {
        guard let walletId = dictionary["walletId"] as? String,
              let targetMonth = dictionary["targetMonth"] as? String,
              let budget = dictionary["budget"] as? Double,
              let budgetBreakdownsData = dictionary["budgetBreakdowns"] as? [[String: Any]],
              let goalsData = dictionary["goals"] as? [[String: Any]] else {
            return nil
        }
        self.walletId = walletId
        self.targetMonth = targetMonth
        self.budgetBreakdowns = budgetBreakdownsData.map { document in
            BudgetBreakdown(dictionary: document)!
        }
        
        self.goals = goalsData.map { document in
            Goal(dictionary: document)!
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "walletId": walletId,
            "targetMonth": targetMonth,
            "budgetBreakdowns": budgetBreakdowns.map { $0.toDictionary() },
            "goals": goals.map { $0.toDictionary() }
        ]
    }
    
    internal func getTotalBudget() -> Double{
        var budget = 0.0
        self.budgetBreakdowns.forEach { breakdown in
            budget += breakdown.amount
        }
        return budget
    }
}

class BudgetBreakdown {
    var id: String
    var title: String
    var amount: Double
    
    init(id: String? = nil, title: String, amount: Double) {
        if id == nil {
            self.id = BudgetBreakdown.getId()
        } else {
            self.id = id!
        }
        self.title = title
        self.amount = amount
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String,
              let amount = dictionary["amount"] as? Double else {
            return nil
        }
        self.id = id
        self.title = title
        self.amount = amount
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "amount": amount
        ]
    }
    
    static func getId() -> String {
        return String(format: "%04d", CGFloat.random(in: 1...1000))
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
