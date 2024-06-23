//
//  Category.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/02.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var icon: String? // アイコンのファイル名やURLなど
    @objc dynamic var color: String? // カラーコードなど
    @objc dynamic var category_type_div: Int = 0
    @objc dynamic var sort_order: Int = 0
    // UserSetting
    @objc dynamic var repeat_flg: Bool = false
    let userSetTransferLogs = List<UserSetTransferLog>()

    convenience init(name: String, icon: String? = nil, color: String? = nil, category_type_div: Int) {
        self.init()
        self.name = name
        self.icon = icon
        self.color = color
        self.category_type_div = category_type_div
        
        self.sort_order = getMaxSortOrder()
    }
    
    private func getMaxSortOrder() -> Int {
        let realm: Realm
        // Realmのインスタンスを取得
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error.localizedDescription)")
        }
        
        if let maxSortOrder = realm.objects(Category.self).max(ofProperty: "sort_order") as Int? {
            return maxSortOrder + 1
        } else {
            return 0
        }
    }
    
    func getTotalOfUserSetTransferLog() -> Double {
        var total: Double = 0.0
        self.userSetTransferLogs.forEach { log in
            total += log.amount
        }
        return total
    }
}
