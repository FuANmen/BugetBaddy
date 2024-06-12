//
//  MonthryBreakDown.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/28.
//

import RealmSwift

class BreakdownDao {
    private let realm: Realm
    
    init() {
        // Realmのインスタンスを取得
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    // 追加メソッド
    func addBreakDown(targetMonth: String, title: String, amount: Double, source_pattern: String) {
        let newBreakDown = Breakdown(targetMonth: targetMonth, title: title, amount: amount, source_pattern: source_pattern)
        let totalGoal = GoalDao().getTotalGoal(targetMonth: targetMonth)
        try? realm.write {
            realm.add(newBreakDown)
        }
    }
    
    // 更新メソッド
    func updateBreakDown(breakdown: Breakdown, title: String? = nil, amount: Double? = nil, sort_order: Int? = nil) {
        let totalGoal = GoalDao().getTotalGoal(targetMonth: breakdown.targetMonth)
        try? realm.write {
            if title != nil { breakdown.title = title! }
            if amount != nil {
                breakdown.amount = amount!
            }
            if sort_order != nil { breakdown.sort_order = sort_order! }
        }
    }

    // 取得メソッド
    func getMonthryBreakdown(targetMonth: String, ascending: Bool? = false) -> Results<Breakdown> {
        let sortProperties = [
            SortDescriptor(keyPath: "amount", ascending: ascending!)
        ]
        return realm.objects(Breakdown.self).filter("targetMonth == %@", targetMonth).sorted(by: sortProperties)
    }
    
    func getMonthryIncomOfBreakdowns(targetMonth: String, ascending: Bool? = false) -> [Breakdown] {
        var breakdowns: [Breakdown] = []
        
        let sortProperties = [
            SortDescriptor(keyPath: "amount", ascending: ascending!)
        ]
        let result = realm.objects(Breakdown.self).filter("targetMonth == %@ && source_pattern = %@", targetMonth, "0").sorted(by: sortProperties)
        
        result.forEach { breakdown in
            breakdowns.append(breakdown)
        }
        return breakdowns
    }
    
    func getMonthryTransferOfBreakdowns(targetMonth: String, ascending: Bool? = false) -> [Breakdown] {
        var breakdowns: [Breakdown] = []
        
        let sortProperties = [
            SortDescriptor(keyPath: "amount", ascending: ascending!)
        ]
        let result = realm.objects(Breakdown.self).filter("targetMonth == %@ && source_pattern = %@", targetMonth, "1").sorted(by: sortProperties)
        
        result.forEach { breakdown in
            breakdowns.append(breakdown)
        }
        return breakdowns
    }
    
    func deleteBreakdown(breakdown: Breakdown) {
        let totalGoal = GoalDao().getTotalGoal(targetMonth: breakdown.targetMonth)
        try? realm.write {
            realm.delete(breakdown)
        }
    }
}
