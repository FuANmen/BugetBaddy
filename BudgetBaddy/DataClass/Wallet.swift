import Foundation

class Wallet {
    var walletId: String
    var name: String
    var ownerId: String
    var is_default: Bool
    var is_private: Bool
    var sharedUsersInfo: [UserInfo]
    var sort_order: Int
    var categories: [Category]
    
    init(walletId: String? = nil, name: String, ownerId: String, is_default: Bool, is_private: Bool, sharedUsersInfo: [UserInfo], sort_order: Int, categories: [Category] = []) {
        if walletId != nil {
            self.walletId = walletId!
        } else {
            self.walletId = Wallet.getId()
        }
        self.name = name
        self.ownerId = ownerId
        self.is_default = is_default
        self.is_private = is_private
        self.sharedUsersInfo = sharedUsersInfo
        self.sort_order = sort_order
        self.categories = categories
    }
    
    init?(dictionary: [String: Any]) {
        guard let walletId = dictionary["walletId"] as? String,
              let name = dictionary["name"] as? String,
              let ownerId = dictionary["ownerId"] as? String,
              let is_default = dictionary["is_default"] as? Bool,
              let is_private = dictionary["is_private"] as? Bool,
              let sharedUsersInfoData = dictionary["sharedUsersInfo"] as? [[String: Any]],
              let sort_order = dictionary["sort_order"] as? Int,
              let categoriesData = dictionary["categories"] as? [[String: Any]] else {
            return nil
        }
        self.walletId = walletId
        self.name = name
        self.ownerId = ownerId
        self.is_default = is_default
        self.is_private = is_private
        self.sharedUsersInfo = sharedUsersInfoData.map { document in
            UserInfo(dictionary: document)!
        }
        self.sort_order = sort_order
        self.categories = categoriesData.map { document in
            Category(dictionary: document)!
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "walletId": walletId,
            "name": name,
            "ownerId": ownerId,
            "is_default": is_default,
            "is_private": is_private,
            "sharedUsersInfo": sharedUsersInfo.map { $0.toDictionary() },
            "sort_order": sort_order,
            "categories": categories.map { $0.toDictionary() }
        ]
    }
    
    static func getId() -> String {
        return String(format: "%04d", Int.random(in: 1...1000))
    }
    
    internal func getCategoryById(categoryId: String) -> Category? {
        if let index = self.categories.firstIndex(where: { $0.categoryId == categoryId }) {
            return self.categories[index]
        } else {
            return nil
        }
    }
}

class UserInfo {
    var userId: String
    var username: String
    
    init(userId: String, username: String) {
        self.userId = userId
        self.username = username
    }
    
    init?(dictionary: [String: Any]) {
        guard let userId = dictionary["userId"] as? String,
              let username = dictionary["username"] as? String else {
            return nil
        }
        self.userId = userId
        self.username = username
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "username": username
        ]
    }
}

class Category {
    var categoryId: String
    var name: String
    var sort_order: Int
    
    init(categoryId: String? = nil, name: String, sort_order: Int = 0) {
        if categoryId != nil {
            self.categoryId = categoryId!
        } else {
            self.categoryId = Category.getId()
        }
        self.name = name
        self.sort_order = sort_order
    }
    
    init?(dictionary: [String: Any]) {
        guard let categoryId = dictionary["categoryId"] as? String,
              let name = dictionary["name"] as? String,
              let sort_order = dictionary["sort_order"] as? Int else {
            return nil
        }
        self.categoryId = categoryId
        self.name = name
        self.sort_order = sort_order
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "categoryId": categoryId,
            "name": name,
            "sort_order": sort_order
        ]
    }
    
    static func getId() -> String {
        return String(format: "%04d", Int.random(in: 1...1000))
    }
}
