//
//  UpdateCommon.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/03/02.
//

import Foundation

func UpdateGoals(targetMonth: String) {
    let categoryDao = CategoryDao()
    let goalDao = GoalDao()
    
    let totalGoal = goalDao.getTotalGoal(targetMonth: targetMonth)
    let otherGoal = goalDao.getOtherGoal(targetMonth: targetMonth)
    let userGoals = goalDao.getUserGoals(targetMonth: targetMonth)
    
    var userGoalsAmount: Double = 0.0
    userGoals.forEach { goal in
        userGoalsAmount += goal.getAmount()
    }
    
    var totalAmount: Double = 0.0
    // 「合計」の目標を新規作成し保存
    if totalGoal == nil{
        // let defaultAmount = (UserDefaults.standard.value(forKey: "MonthlyDefaultManagementAmount") as? String)!
        BreakdownDao().getMonthryBreakdown(targetMonth: targetMonth).forEach {item in
            totalAmount += item.amount
        }
        // 「合計」のカテゴリを取得または作成
        let totalCategory = CategoryDao().getOrCreateTotalCategory()
        // 「合計」の目標を作成し保存
        GoalDao().addGoal(targetMonth: targetMonth, isExpenseControlled: false, category: totalCategory, is_total: true)
    } else {
        totalAmount = totalGoal!.getAmount()
    }

    // 管理金額を超えない場合、「その他」の目標として追加
    let confirmedAmount =  userGoalsAmount
    if otherGoal == nil {
        // 「その他」のカテゴリを取得または作成
        let otherCategory = CategoryDao().getOrCreateOtherCategory()
        // 「その他」の目標を作成し保存
        GoalDao().addGoal(targetMonth: targetMonth, isExpenseControlled: false, category: otherCategory, is_other: true)
    }
}
