//
//  Goal.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/01.  
//

import RealmSwift

class Goal: Object {
    @objc dynamic var createdOn: Date = Date()
    @objc dynamic var targetMonth: String = "" // 何年何月の目標かを示す文字列
    @objc dynamic var isExpenseControlled: Bool = true // 支出を抑える目標かどうか
    @objc dynamic var createdByUser_flg = false
    @objc dynamic var is_total = false
    @objc dynamic var is_other = false
    @objc dynamic var category: Category?
    // TargetAmount
    let transLogsAsDest = List<TransferLog>()
    let transLogsAsSour = List<TransferLog>()
    // Alert
    @objc dynamic var alert_flg: Bool = false


    convenience init(targetMonth: String, category: Category, isExpenseControlled: Bool? = false, createdByUser_flg: Bool? = false, is_total: Bool? = false, is_other: Bool? = false, alert_flg: Bool = false) {
        self.init()
        self.targetMonth = targetMonth
        self.isExpenseControlled = isExpenseControlled!
        self.createdByUser_flg = createdByUser_flg!
        self.is_total = is_total!
        self.is_other = is_other!
        self.category = category
        self.alert_flg = alert_flg
    }
    
    func getAmount() -> Double {
        var amount = 0.0
        // 振替先
        if self.is_total || self.is_other {
            let breakdowns = BreakdownDao().getMonthryBreakdown(targetMonth: self.targetMonth)
            breakdowns.forEach { breakdown in
                amount += breakdown.amount
            }
        } else {
            self.transLogsAsDest.forEach{ transferLog in
                amount += transferLog.amount
            }
        }
        // 振替元
        self.transLogsAsSour.forEach { transferLog in
            amount -= transferLog.amount
        }
        
        if self.is_other && amount < 0 {
            return 0
        }
        
        return amount
    }
    
    func getBalance() -> Double {
        return self.getAmount() - self.getTransactionsAmountSum()
    }
    
    func getTransactions(sortedBy: String? = nil, ascending_flg: Bool? = nil) -> [Transaction] {
        if self.is_total {
            return TransactionDao().getTotalTransactions(targetMonth: self.targetMonth)
        } else if self.is_other {
            var result: [Transaction] = []
            
            let categories = CategoryDao().getCategories().filter("category_type_div == 0")
            let goals = GoalDao().getInExGoals(targetMonth: self.targetMonth)
            
            categories.forEach { category in
                var is_contain: Bool = false
                
                goals.forEach { goal in
                    if category.name == goal.category!.name { is_contain = true }
                }
                print(category.name + "," + String(is_contain))
                if !is_contain {
                    result.append(contentsOf: TransactionDao().getTransactionsForCategory(category: category, targetMonth: self.targetMonth))
                }
            }
            return result.sorted(by:{$0.date < $1.date})
        } else {
            return TransactionDao().getTransactionsForCategory(category: self.category!, targetMonth: self.targetMonth, sortedBy: sortedBy, ascending_flg: ascending_flg)
        }
    }
    
    func getTransactionsAtDate(date: Date) -> [Transaction] {
        if self.is_other {
            var result: [Transaction] = []
            
            let categories = CategoryDao().getCategories().filter("category_type_div == 0")
            let goals = GoalDao().getInExGoals(targetMonth: self.targetMonth)
            
            categories.forEach { category in
                var is_contain: Bool = false
                
                goals.forEach { goal in
                    if category.name == goal.category!.name { is_contain = true }
                }
                
                if !is_contain {
                    result.append(contentsOf: TransactionDao().getTransactionsAtDate(category: category, date: date))
                }
            }
            return result.sorted(by:{$0.date < $1.date})
        } else {
            return TransactionDao().getTransactionsAtDate(category: self.category!, date: date)
        }
    }
    
    // Transactionの合計値取得
    func getTransactionsAmountSum() -> Double {
        var amount = 0.0
        self.getTransactions().forEach {tran in
            amount += tran.amount
        }
        return amount
    }
}
