//
//  GoalDao.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/25.
//

import Foundation
import FirebaseFirestore

class MonthlyGoalsDao {
    static func getMonthlyGoalsDocumentId(walletId: String, targetMonth: String) -> String {
        return "\(walletId)-\(targetMonth)"
    }
    
    // MARK: - MonthlyGoals
    static func addMonthlyGoals(monthlyGoals: MonthlyGoals) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: monthlyGoals.walletId, targetMonth: monthlyGoals.targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        monthlyGoalsRef.setData(monthlyGoals.toDictionary()) { error in
            if let error = error {
                print("Error adding MonthlyGoals: \(error)")
            } else {
                print("MonthlyGoals added successfully")
            }
        }
    }
    
    static func updateMonthlyGoals(editedMonthlyGoals: MonthlyGoals) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: editedMonthlyGoals.walletId, targetMonth: editedMonthlyGoals.targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        monthlyGoalsRef.updateData([
            "budget": editedMonthlyGoals.budget
        ]) { error in
            if let error = error {
                print("Error update Wallet: \(error)")
            } else {
                print("Update wallet successfully")
            }
        }
    }
    
    static func deleteMonthlyGoals(monthlyGoals: MonthlyGoals, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: monthlyGoals.walletId, targetMonth: monthlyGoals.targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        monthlyGoalsRef.delete { error in
            if let error = error {
                print("Error deleting MonthlyGoals: \(error)")
                completion(error)
            } else {
                print("MonthlyGoals successfully deleted")
                completion(nil)
            }
        }
    }
    
    static func fetchMonthlyGoals(walletId: String, targetMonth: String, completion: @escaping (MonthlyGoals?) -> Void) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let monthlyGoals = MonthlyGoals(dictionary: data!)
                completion(monthlyGoals)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - TransferLog
    static func addTransferLogToMonthlyGoals(walletId: String, targetMonth: String, newTransferLog: TransferLog) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        let newTransferLogData = newTransferLog.toDictionary()
        
        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                monthlyGoalsRef.updateData([
                    "transferLogs": FieldValue.arrayUnion([newTransferLogData])
                ]) { error in
                    if let error = error {
                        print("Error adding TransferLog to MonthlyGoals: \(error)")
                    } else {
                        print("TransferLog added to MonthlyGoals successfully")
                    }
                }
            } else {
                print("MonthlyGoals document does not exist")
            }
        }
    }
    
    static func updateTransferLogInMonthlyGoals(walletId: String, targetMonth: String, editedTransferLog: TransferLog) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var monthlyGoalsData = document.data()!

                monthlyGoalsRef.updateData([
                    "title": editedTransferLog.title,
                    "amount": editedTransferLog.amount
                ]) { error in
                    if let error = error {
                        print("Error update TransferLog from MonthlyGoals: \(error)")
                    } else {
                        print("TransferLog update from MonthlyGoals successfully")
                    }
                }
            } else {
                print("MonthlyGoals document does not exist")
            }
        }
    }
    
    static func removeTransferLogFromMonthlyGoals(walletId: String, targetMonth: String, transferLog: TransferLog) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        let transferLogData = transferLog.toDictionary()

        monthlyGoalsRef.updateData([
            "transferLogs": FieldValue.arrayRemove([transferLogData])
        ]) { error in
            if let error = error {
                print("Error removing category from Wallet: \(error)")
            } else {
                print("Category removed from wallet successfully")
            }
        }
    }
    
    // MARK: - Goals
    static func addGoalToMonthlyGoals(walletId: String, targetMonth: String, newGoal: Goal) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        let newGoalData = newGoal.toDictionary()
        
        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                monthlyGoalsRef.updateData([
                    "goals": FieldValue.arrayUnion([newGoalData])
                ]) { error in
                    if let error = error {
                        print("Error adding goal to MonthlyGoals: \(error)")
                    } else {
                        print("Goal added to MonthlyGoals successfully")
                    }
                }
            } else {
                print("MonthlyGoals document does not exist")
            }
        }
    }
    
    static func updateGoalInMonthlyGoals(walletId: String, targetMonth: String, editedGoal: Goal) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var monthlyGoalsData = document.data()!

                monthlyGoalsRef.updateData([
                    "categoryId": editedGoal.categoryId,
                    "budget": editedGoal.budget
                ]) { error in
                    if let error = error {
                        print("Error update Goal from MonthlyGoals: \(error)")
                    } else {
                        print("Goal update from MonthlyGoals successfully")
                    }
                }
            } else {
                print("MonthlyGoals document does not exist")
            }
        }
    }
    
    static func removeGoalFromMonthlyGoals(walletId: String, targetMonth: String, goal: Goal) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        let goalData = goal.toDictionary()

        monthlyGoalsRef.updateData([
            "goals": FieldValue.arrayRemove([goalData])
        ]) { error in
            if let error = error {
                print("Error removing category from Wallet: \(error)")
            } else {
                print("Category removed from wallet successfully")
            }
        }
    }
}
