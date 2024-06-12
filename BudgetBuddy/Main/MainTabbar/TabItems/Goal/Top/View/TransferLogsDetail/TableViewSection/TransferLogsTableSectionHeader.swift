//
//  GoalOfTransferLogsViewSectionHeader.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/24.
//

import UIKit

protocol TransferLogsTableSectionHeaderDelegate: AnyObject {
    func openAndCloseCellBtnTapped(sectionNum: Int)
}

class TransferLogsTableSectionHeader: UIView {
    static let sectionHeight: CGFloat = 36.0
    
    weak var delegate: TransferLogsTableSectionHeaderDelegate?
    internal var expanded: Bool = false
    
    private var sectionNum: Int? = nil
    private var category: Category? = nil
    
    private let openAndCloseCellBtn: UIButton = {
        let button = UIButton()
        button.tintColor = .systemGray5
        button.alpha = 0.6
        button.addTarget(self, action: #selector(openAndCloseCellBtnTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        label.textColor = .white
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Total", comment: "") + " : "
        label.font = UIFont.systemFont(ofSize: 22, weight: .light)
        label.textColor = .white
        return label
    }()
    
    private let amountValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .light)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(openAndCloseCellBtn)
        addSubview(titleLabel)
        addSubview(amountLabel)
        addSubview(amountValue)
        openAndCloseCellBtn.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountValue.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            openAndCloseCellBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            openAndCloseCellBtn.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: openAndCloseCellBtn.trailingAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            
            amountLabel.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: -4),
            amountLabel.centerYAnchor.constraint(equalTo: amountValue.centerYAnchor),
            
            amountValue.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            amountValue.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure(goal: Goal, sectionNum: Int, expanded: Bool) {
        self.category = goal.category
        titleLabel.text = goal.category!.name
        amountValue.text = formatCurrency(amount: goal.getAmount())!
        openAndCloseCellBtn.setImage(UIImage(systemName: expanded ? "chevron.up" : "chevron.down"), for: .normal)
        self.sectionNum = sectionNum
    }
    
    @objc private func openAndCloseCellBtnTapped() {
        self.expanded.toggle()
        openAndCloseCellBtn.setImage(UIImage(systemName: expanded ? "chevron.up" : "chevron.down"), for: .normal)
        self.delegate!.openAndCloseCellBtnTapped(sectionNum: self.sectionNum!)
    }
}
