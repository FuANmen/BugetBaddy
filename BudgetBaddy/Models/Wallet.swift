import Foundation

class Wallet {
    var walletId: String
    var name: String
    var ownerInfo: UserInfo
    var is_default: Bool
    var is_private: Bool
    var sharedUsersInfo: [UserInfo]
    var sort_order: Int
    var categories: [Category]
    
    init(walletId: String, name: String, ownerInfo: UserInfo, is_default: Bool, is_private: Bool, sharedUsersInfo: [UserInfo], sort_order: Int, categories: [Category] = []) {
        self.walletId = walletId
        self.name = name
        self.ownerInfo = ownerInfo
        self.is_default = is_default
        self.is_private = is_private
        self.sharedUsersInfo = sharedUsersInfo
        self.sort_order = sort_order
        self.categories = categories
    }
    
    init?(dictionary: [String: Any]) {
        guard let walletId = dictionary["walletId"] as? String,
              let name = dictionary["name"] as? String,
              let ownerInfoData = dictionary["ownerInfo"] as? [String: Any],
              let is_default = dictionary["is_default"] as? Bool,
              let is_private = dictionary["is_private"] as? Bool,
              let sharedUsersInfoData = dictionary["sharedUsersInfo"] as? [[String: Any]],
              let sort_order = dictionary["sort_order"] as? Int,
              let categoriesData = dictionary["categories"] as? [[String: Any]] else {
            return nil
        }
        self.walletId = walletId
        self.name = name
        self.ownerInfo = UserInfo(dictionary: ownerInfoData)!
        
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
}

class Category {
    var categoryId: String
    var name: String
    var sort_order: Int
    
    init(categoryId: String, name: String, sort_order: Int) {
        self.categoryId = categoryId
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
}
