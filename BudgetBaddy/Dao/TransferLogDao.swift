//
//  TransferLogDao.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/04/30.
//

import RealmSwift

class TransferLogDao {
    private var realm: Realm

    init() {
        do {
            realm = try Realm()
        } catch let error {
            fatalError("Failed to instantiate Realm: \(error)")
        }
    }

    // Create a new TransferLog entry
    func createTransferLog(targetMonth: String,sourCategory: Category, destCategory: Category, amount: Double, title: String) -> TransferLog {
        let transferLog = TransferLog(amount: amount, title: title)
        
        // 振替元取得
        var source: Goal?
        
        if sourCategory.category_type_div == 3 {
            // カテゴリのtypeが '3'(Other)のとき
            source = GoalDao().getOtherGoal(targetMonth: targetMonth)
        } else {
            let goals = GoalDao().getInExGoals(targetMonth: targetMonth)
            goals.forEach { goal in
                if goal.category!.name == destCategory.name {
                    source = goal
                }
            }
        }
        
        // 宛先カテゴリのGoalが存在チェックし、宛先Goalを取得する
        var goalExsistFlg = false
        var destination: Goal? = nil
        let goals = GoalDao().getInExGoals(targetMonth: targetMonth)
        goals.forEach { goal in
            if goal.category!.name == destCategory.name {
                // 宛先カテゴリのGoalがあるとき、このGoalを宛先Goalとする
                goalExsistFlg = true
                destination = goal
            }
        }
        if !goalExsistFlg {
            // 宛先Goalが存在しないとき、新規作成する
            destination = GoalDao().addGoal(targetMonth: targetMonth, category: destCategory, createdByUser_flg: true)
        }
        
        do {
            try realm.write {
                transferLog.created_on = Date()
                realm.add(transferLog)
                source!.transLogsAsSour.append(transferLog)
                destination!.transLogsAsDest.append(transferLog)
            }
        } catch let error {
            print("Failed to create TransferLog: \(error)")
        }
        
        return transferLog
    }

    // Retrieve all TransferLogs
    func getAllTransferLogs() -> Results<TransferLog> {
        return realm.objects(TransferLog.self)
    }

    // Update a TransferLog
    func updateTransferLog(transferLog: TransferLog, newAmount: Double) {
        do {
            try realm.write {
                transferLog.amount = newAmount
            }
        } catch let error {
            print("Failed to update TransferLog: \(error)")
        }
    }

    // Delete a TransferLog
    func deleteTransferLog(transferLog: TransferLog) {
        do {
            try realm.write {
                realm.delete(transferLog)
            }
        } catch let error {
            print("Failed to delete TransferLog: \(error)")
        }
    }
}
