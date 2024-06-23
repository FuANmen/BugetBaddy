//
//  UserSetTransferLogDao.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/11.
//

import RealmSwift

class UserSetTransferLogDao {
    private var realm: Realm

    init() {
        do {
            realm = try Realm()
        } catch let error {
            fatalError("Failed to instantiate Realm: \(error)")
        }
    }

    // Create a new UserSetTransferLog entry
    func createUserSetTransferLog(userSetTransferLog: UserSetTransferLog, category: Category) {
        do {
            try realm.write {
                realm.add(userSetTransferLog)
                category.userSetTransferLogs.append(userSetTransferLog)
            }
        } catch let error {
            print("Failed to create TransferLog: \(error)")
        }
    }
    
    func updateUserSetTransferLog(userSetTransferLog: UserSetTransferLog, title: String, amount: Double) {
        try? realm.write {
            userSetTransferLog.title = title
            userSetTransferLog.amount = amount
        }
    }

    // Delete a UserSetTransferLog
    func deleteUserSEtTransferLog(userSetTransferLog: UserSetTransferLog) {
        do {
            try realm.write {
                realm.delete(userSetTransferLog)
            }
        } catch let error {
            print("Failed to delete TransferLog: \(error)")
        }
    }
}
