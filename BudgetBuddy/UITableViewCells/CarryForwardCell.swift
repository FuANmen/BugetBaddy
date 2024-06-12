//
//  CarryForwardCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/03/14.
//

import UIKit

protocol CarryForwardCellDelegate: AnyObject {
    func showDetail(targetMonth: String?)
}

class CarryForwardCell: UITableViewCell {
    private var breakdownDao = BreakdownDao()
    
    weak var delegate: CarryForwardCellDelegate?
    static let identifier = "CarryForwardCell"
    static let defaultHeight: CGFloat = 60.0
    static let selectedHeight: CGFloat = 180.0
    
    private var targetMonth: String?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private let partitionLineView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        return view
    }()
    
    private let detailViewAria: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.alpha = 0.0
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 1
        view.layer.masksToBounds = false
        return view
    }()
    
    private let incomLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Income", comment: "") + ":"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    private var incomAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    private let transferLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Transfer", comment: "") + ":"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    private var transferAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    private let expensesLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Expenses", comment: "") + ":"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    private var expensesAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    private let showDetailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.compact.right"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .systemTeal
        button.alpha = 0.6
        button.addTarget(self, action: #selector(showDetailButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(partitionLineView)
        contentView.addSubview(detailViewAria)
        detailViewAria.addSubview(showDetailButton)
        detailViewAria.addSubview(incomLabel)
        detailViewAria.addSubview(incomAmountLabel)
        detailViewAria.addSubview(transferLabel)
        detailViewAria.addSubview(transferAmountLabel)
        detailViewAria.addSubview(expensesLabel)
        detailViewAria.addSubview(expensesAmountLabel)
        
        // Add constraints for labels
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        partitionLineView.translatesAutoresizingMaskIntoConstraints = false
        detailViewAria.translatesAutoresizingMaskIntoConstraints = false
        showDetailButton.translatesAutoresizingMaskIntoConstraints = false
        incomLabel.translatesAutoresizingMaskIntoConstraints = false
        incomAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        transferLabel.translatesAutoresizingMaskIntoConstraints = false
        transferAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        expensesLabel.translatesAutoresizingMaskIntoConstraints = false
        expensesAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: CarryForwardCell.defaultHeight / 2),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            balanceLabel.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: CarryForwardCell.defaultHeight / 2),
            balanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            partitionLineView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CarryForwardCell.defaultHeight),
            partitionLineView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            partitionLineView.heightAnchor.constraint(equalToConstant: 6),
            
            detailViewAria.topAnchor.constraint(equalTo: partitionLineView.bottomAnchor, constant: 0),
            detailViewAria.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailViewAria.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailViewAria.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // DetailViewArea
            showDetailButton.centerYAnchor.constraint(equalTo: detailViewAria.centerYAnchor),
            showDetailButton.trailingAnchor.constraint(equalTo: detailViewAria.trailingAnchor, constant: -4),
            
            incomLabel.topAnchor.constraint(equalTo: detailViewAria.topAnchor, constant: 16),
            incomLabel.leadingAnchor.constraint(equalTo: detailViewAria.leadingAnchor, constant: 16),
            incomAmountLabel.centerYAnchor.constraint(equalTo: incomLabel.centerYAnchor),
            incomAmountLabel.trailingAnchor.constraint(equalTo: showDetailButton.leadingAnchor, constant: -40),
            
            transferLabel.topAnchor.constraint(equalTo: incomLabel.bottomAnchor, constant: 8),
            transferLabel.leadingAnchor.constraint(equalTo: detailViewAria.leadingAnchor, constant: 16),
            transferAmountLabel.centerYAnchor.constraint(equalTo: transferLabel.centerYAnchor),
            transferAmountLabel.trailingAnchor.constraint(equalTo: showDetailButton.leadingAnchor, constant: -40),
            
            expensesLabel.topAnchor.constraint(equalTo: transferLabel.bottomAnchor, constant: 16),
            expensesLabel.leadingAnchor.constraint(equalTo: detailViewAria.leadingAnchor, constant: 16),
            expensesAmountLabel.centerYAnchor.constraint(equalTo: expensesLabel.centerYAnchor),
            expensesAmountLabel.trailingAnchor.constraint(equalTo: showDetailButton.leadingAnchor, constant: -40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(goal: Goal) {
        self.targetMonth = goal.targetMonth
        
        titleLabel.text = goal.targetMonth.suffix(2) + NSLocalizedString("Month", comment: "") + " :"
        let balance = goal.getBalance()
        let moneyLabel = NSLocalizedString("Money", comment: "")
        if balance == 0 {
            balanceLabel.textColor = .systemGray2
            balanceLabel.text = moneyLabel + String(Int(balance))
        } else if balance >= 0 {
            balanceLabel.textColor = .systemGreen
            balanceLabel.text = "+" + moneyLabel + String(Int(balance))
        } else {
            balanceLabel.textColor = .systemRed
            balanceLabel.text = "-" + moneyLabel + String(Int(abs(balance)))
        }
        
        // DetailViewAria
        let incomBreakdowns = breakdownDao.getMonthryIncomOfBreakdowns(targetMonth: self.targetMonth!)
        let transBreakdowns = breakdownDao.getMonthryTransferOfBreakdowns(targetMonth: self.targetMonth!)
        
        var incomAmount = 0.0
        incomBreakdowns.forEach { breakdown in
            incomAmount += breakdown.amount
        }
        var transAmount = 0.0
        transBreakdowns.forEach { breakdown in
            transAmount += breakdown.amount
        }
        self.incomAmountLabel.text = formatCurrency(amount: incomAmount)
        self.transferAmountLabel.text = formatCurrency(amount: transAmount)
        self.expensesAmountLabel.text = formatCurrency(amount: goal.getTransactionsAmountSum())
    }
    
    func selected(selected: Bool) {
        UIView.animate(withDuration: selected ? 0.3 : 0.0) {
            self.detailViewAria.alpha = selected ? 1.0 : 0.0
        }
    }
    
    @objc func showDetailButtonTapped() {
        delegate!.showDetail(targetMonth: self.targetMonth)
    }
}
