//
//  GoalsTotalView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/20.
//

import UIKit

protocol TotalGoalViewDelegate: AnyObject {
    func showTotalDetail()
}

class TotalGoalView: UIView {
    weak var delegate: TotalGoalViewDelegate?
    
    var thisGoal: Goal?
    
    func configure(goal: Goal) {
        thisGoal = goal
        //label_title.text = goal.category.first!.name
        label_amount.text = "\(NSLocalizedString("GoCell_Label_2", comment: "")): " + formatCurrency(amount: thisGoal!.amount)!
        
        let balance = thisGoal!.amount + thisGoal!.getTransactionsAmountSum()
        label_balance.text = formatCurrency(amount: balance)
        
        setupUI()
    }
    
    private func setupUI() {
        self.addSubview(label_title)
        self.addSubview(label_amount)
        self.addSubview(label_balance)
        self.addSubview(showDetailButton)
        
        label_title.translatesAutoresizingMaskIntoConstraints = false
        label_amount.translatesAutoresizingMaskIntoConstraints = false
        label_balance.translatesAutoresizingMaskIntoConstraints = false
        showDetailButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label_title.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            label_title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            
            showDetailButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            showDetailButton.heightAnchor.constraint(equalTo: self.heightAnchor),
            showDetailButton.widthAnchor.constraint(equalToConstant: 20),
            showDetailButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            label_balance.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            label_balance.trailingAnchor.constraint(equalTo: showDetailButton.leadingAnchor, constant: -12),
            
            label_amount.bottomAnchor.constraint(equalTo: label_balance.topAnchor, constant: -4),
            label_amount.trailingAnchor.constraint(equalTo: label_balance.trailingAnchor, constant: 0)
        ])
    }
    
    @objc func tappedShowDetailButton() {
        delegate?.showTotalDetail()
    }
}
