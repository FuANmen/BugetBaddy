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
    
    static func fetchMonthlyGoals(walletId: String, targetMonth: String) async -> MonthlyGoals? {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)
        do {
            let document = try await monthlyGoalsRef.getDocument()
            if let data = document.data() {
                let monthlyGoals = MonthlyGoals(dictionary: data)
                print("Fetch monthly goals")
                return monthlyGoals
            } else {
                return nil
            }
        } catch {
            print("Error fetching document: \(error)")
            return nil
        }
    }
    
    // MARK: - BudgetBreakdown
    static func addBudgetBreakdownToMonthlyGoals(walletId: String, targetMonth: String, newBudgetBreakdown: BudgetBreakdown) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        let newBudgetBreakdownData = newBudgetBreakdown.toDictionary()
        
        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                monthlyGoalsRef.updateData([
                    "budgetBreakdowns": FieldValue.arrayUnion([newBudgetBreakdownData])
                ]) { error in
                    if let error = error {
                        print("Error adding BudgetBreakdown to MonthlyGoals: \(error)")
                    } else {
                        print("BudgetBreakdown added to MonthlyGoals successfully")
                    }
                }
            } else {
                print("MonthlyGoals document does not exist")
            }
        }
    }
    
    static func updateBudgetBreakdownInMonthlyGoals(walletId: String, targetMonth: String, editedBudgetBreakdown: BudgetBreakdown) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)
        
        let editedBudgetBreakdownData = editedBudgetBreakdown.toDictionary()

        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var monthlyGoalsData = document.data()!
                var breakdowns = monthlyGoalsData["budgetBreakdowns"] as! [[String: Any]]
                
                if let index = breakdowns.firstIndex(where: { $0["id"] as? String == editedBudgetBreakdown.id }) {
                    breakdowns[index] = editedBudgetBreakdownData
                } else {
                    print("Breakdown not found")
                    return
                }
                
                // Firestoreドキュメントを更新
                monthlyGoalsRef.updateData([
                    "budgetBreakdowns": breakdowns
                ]) { error in
                    if let error = error {
                        print("Error update BudgetBreakdown from MonthlyGoals: \(error)")
                    } else {
                        print("BudgetBreakdown update from MonthlyGoals successfully")
                    }
                }
            } else {
                print("MonthlyGoals document does not exist")
            }
        }
    }
    
    static func removeBudgetBreakdownFromMonthlyGoals(walletId: String, targetMonth: String, budgetBreakdown: BudgetBreakdown) {
        let db = Firestore.firestore()
        let documentId = MonthlyGoalsDao.getMonthlyGoalsDocumentId(walletId: walletId, targetMonth: targetMonth)
        let monthlyGoalsRef = db.collection("MonthlyGoals").document(documentId)

        let budgetBreakdownData = budgetBreakdown.toDictionary()

        monthlyGoalsRef.updateData([
            "budgetBreakdown": FieldValue.arrayRemove([budgetBreakdownData])
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
        
        let editedGoalData = editedGoal.toDictionary()

        monthlyGoalsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var monthlyGoalsData = document.data()!
                var goals = monthlyGoalsData["goals"] as! [[String: Any]]
                
                if let index = goals.firstIndex(where: { $0["categoryId"] as? String == editedGoal.categoryId }) {
                    goals[index] = editedGoalData
                } else {
                    print("Goal not found")
                    return
                }
                
                // Firestoreドキュメントを更新
                monthlyGoalsRef.updateData([
                    "goals": goals
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
