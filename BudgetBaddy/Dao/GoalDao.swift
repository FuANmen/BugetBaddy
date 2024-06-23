//
//  GoalDao.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/05.
//

import RealmSwift

class GoalDao {
    private let realm: Realm
    
    init() {
        // Realmのインスタンスを取得
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    // Goalを追加するメソッド
    func addGoal(targetMonth: String, isExpenseControlled: Bool? = false, category: Category, createdByUser_flg:Bool? = false, is_total: Bool? = false, is_other: Bool? = false) -> Goal {
        let newGoal = Goal(targetMonth: targetMonth, category: category, isExpenseControlled: isExpenseControlled!, createdByUser_flg: createdByUser_flg, is_total: is_total!, is_other: is_other)
        try? realm.write {
            realm.add(newGoal)
        }
        return newGoal
    }

    // Goalを取得するメソッド
    func getGoals(targetMonth: String) -> Results<Goal> {
        let sortProperties = [
          SortDescriptor(keyPath: "is_total", ascending: false),
          SortDescriptor(keyPath: "createdByUser_flg", ascending: false),
          SortDescriptor(keyPath: "is_other", ascending: false)
        ]
        return realm.objects(Goal.self).filter("targetMonth == %@", targetMonth).sorted(by: sortProperties)
    }
    
    func getGoalsByCategory(category: Category) -> Results<Goal> {
        let sortProperties = [
          SortDescriptor(keyPath: "targetMonth", ascending: true)
        ]
        return realm.objects(Goal.self).where({$0.category.name == category.name }).sorted(by: sortProperties)
    }
    
    func getGoalsByCategory(category: Category, targetMonth: String) -> Results<Goal> {
        let sortProperties = [
          SortDescriptor(keyPath: "targetMonth", ascending: true)
        ]
        return realm.objects(Goal.self).where({$0.targetMonth == targetMonth && $0.category.name == category.name}).sorted(by: sortProperties)
    }
    
    func getTotalGoal(targetMonth: String) -> Goal? {
        return realm.objects(Goal.self).filter("targetMonth == %@ AND is_total == true", targetMonth).first
    }
    
    func getUserGoals(targetMonth: String) -> Results<Goal> {
        return realm.objects(Goal.self).filter("targetMonth == %@ AND createdByUser_flg == true", targetMonth)
    }
    
    func getInExGoals(targetMonth: String, sortedBy: String? = "category.sort_order", ascending_flg: Bool? = false) -> [Goal] {
        var resultGoals: [Goal] = []
        
        let checkedSortedBy = checkPropDetail(str: sortedBy!)
        if checkedSortedBy.className == "" {
            if checkedSortedBy.property == "amount" {
                let res = realm.objects(Goal.self).filter("targetMonth == %@ AND createdByUser_flg == true", targetMonth)
                res.forEach { goal in
                    if resultGoals.count == 0 {
                        resultGoals.append(goal)
                    } else {
                        var flg = false
                        for i in 0..<resultGoals.count {
                            let target = resultGoals[i]
                            
                            if !ascending_flg! {
                                if target.getAmount() < goal.getAmount() {
                                    resultGoals.insert(goal, at: i)
                                    flg = true
                                }
                            } else {
                                if target.getAmount() > goal.getAmount() {
                                    resultGoals.insert(goal, at: i)
                                    flg = true
                                }
                            }
                        }
                        
                        if !flg {
                            resultGoals.append(goal)
                        }
                    }
                }
            } else {
                let sortProperties = [
                    SortDescriptor(keyPath: checkedSortedBy.property, ascending: ascending_flg!)
                ]
                let res = realm.objects(Goal.self).filter("targetMonth == %@ AND createdByUser_flg == true", targetMonth).sorted(by: sortProperties)
                resultGoals.append(contentsOf: res)
            }
        } else if checkedSortedBy.className == "category" {
            // TODO: カテゴリによる並べ替え
            
            let res = realm.objects(Goal.self).filter("targetMonth == %@ AND createdByUser_flg == true", targetMonth)
            resultGoals.append(contentsOf: res)
        }
        return resultGoals
    }
    func getOtherGoal(targetMonth: String) -> Goal? {
        return realm.objects(Goal.self).filter("targetMonth == %@ AND is_other == true", targetMonth).first
    }
    
    // Goalを更新するメソッド
    func updateGoal(goal: Goal, targetMonth: String? = nil, isExpenseControlled: Bool? = false, alert_flg: Bool? = nil) {
        try? realm.write {
            if targetMonth != nil {
                goal.targetMonth = targetMonth!
            }
            if alert_flg != nil {
                goal.alert_flg = alert_flg!
            }
            goal.isExpenseControlled = isExpenseControlled!
        }
    }
    
    // Goalを削除するメソッド
    func deleteJustGoal(goal: Goal) {
        try? realm.write {
            realm.delete(goal)
        }
    }
    func deleteGoal(goal: Goal) {
        let transferLogsDao = TransferLogDao()
        let transactions = TransactionDao().getTransactionsForCategory(category: goal.category!, targetMonth: goal.targetMonth)
    
        // TransferLog(宛先)を削除
        goal.transLogsAsDest.forEach { transfer in
            transferLogsDao.deleteTransferLog(transferLog: transfer)
        }
        // TransferLog(送り元)の送り元を"Other"に更新
        goal.transLogsAsSour.forEach { transfer in
            let otherGoal = self.getOtherGoal(targetMonth: goal.targetMonth)
            self.addTransfer(goal: otherGoal!, transferlog: transfer, is_source: true)
        }
        
        try? realm.write {
            realm.delete(goal)
        }
    }
    
    private func addTransfer(goal: Goal, transferlog: TransferLog, is_source: Bool) {
        do {
            try realm.write {
                if is_source {
                    goal.transLogsAsSour.append(transferlog)
                } else {
                    goal.transLogsAsDest.append(transferlog)
                }
            }
        } catch let error {
            print("Failed to create TransferLog: \(error)")
        }
    }
}
