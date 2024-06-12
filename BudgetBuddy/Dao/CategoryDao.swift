//
//  CategoryDao.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/05.
//

import RealmSwift

class CategoryDao {
    private let realm: Realm
    
    init() {
        // Realmのインスタンスを取得
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    // カテゴリを追加するメソッド
    func addCategory(name: String, icon: String? = nil, color: String? = nil, category_type_div: Int) {
        let newCategory = Category(name: name,
                                   icon: icon, color: color,
                                   category_type_div: category_type_div)
        try? realm.write {
            realm.add(newCategory)
        }
    }
    
    // カテゴリを更新するメソッド
    func updateCategory(category: Category, name: String? = nil, repeat_flg: Bool? = nil) {
        try? realm.write {
            if name != nil {
                category.name = name!
            }
            if repeat_flg != nil {
                category.repeat_flg = repeat_flg!
            }
        }
    }

    // カテゴリを取得するメソッド
    func getCategories() -> Results<Category> {
        return realm.objects(Category.self)
    }
    
    func getCategory(name: String) -> Category? {
        let res = realm.objects(Category.self).filter("name == %@", name)
        if res.count > 0 {
            return res.first!
        } else {
            return nil
        }
    }
    
    func getUsersCategory(name: String) -> Category? {
        let res = realm.objects(Category.self).filter("name == %@ AND category_type_div == 0", name)
        if res.count > 0 {
            return res.first!
        } else {
            return nil
        }
    }
    
    func getUserCategories(sortedBy: String? = "sort_order", ascending_flg: Bool? = false) -> [Category] {
        let checkedSortedBy = checkPropDetail(str: sortedBy!)
        if checkedSortedBy.className == "" {
            let sortProperties = [
                SortDescriptor(keyPath: checkedSortedBy.property, ascending: ascending_flg!)
            ]
            return Array(realm.objects(Category.self).filter("category_type_div == 0").sorted(by: sortProperties))
        }
        return Array(realm.objects(Category.self).filter("category_type_div == 0"))
    }
    
    func getSavingsPlanCategory(name: String) -> Category? {
        let res = realm.objects(Category.self).filter("name == %@ AND category_type_div == 1", name)
        if res.count > 0 {
            return res.first!
        } else {
            return nil
        }
    }
    
    // 合計カテゴリ
    func getOrCreateTotalCategory() -> Category {
        var totalCategory = realm.objects(Category.self).filter("category_type_div == 2").first
        if totalCategory == nil {
            self.addCategory(name: NSLocalizedString("Total", comment: ""), category_type_div: 2)
            totalCategory = realm.objects(Category.self).filter("category_type_div == 2").first
        }
        return totalCategory!
    }
    
    // その他カテゴリ
    func getOrCreateOtherCategory() -> Category {
        var otherCategory = realm.objects(Category.self).filter("category_type_div == 3").first
        if otherCategory == nil {
            self.addCategory(name: NSLocalizedString("Other", comment: ""), category_type_div: 3)
            otherCategory = realm.objects(Category.self).filter("category_type_div == 3").first
        }
        return otherCategory!
    }
    
    func getOrCreateSavingsPlanCategory(name: String, icon: String? = nil, color: String? = nil) -> Category {
        var category = self.getSavingsPlanCategory(name: name)
        if category == nil {
            self.addCategory(name: name, icon: icon, color: color, category_type_div: 1)
            category = self.getSavingsPlanCategory(name: name)
        }
        return category!
    }
}
