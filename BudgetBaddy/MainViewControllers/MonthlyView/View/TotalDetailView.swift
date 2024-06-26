//
//  TotalDetailView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/23.
//

import UIKit

protocol TotalDetailDelegate: AnyObject {
    func addBreakdownTapped()
    func breakdownSelected(target: BudgetBreakdown)
    func addTransactionTapped()
    func transactionSelected(target: Transaction)
    func updatedTotalDetailViewHeight(viewHeight: CGFloat)
}

class TotalDetailView: UIView {
    weak var delegate: TotalDetailDelegate? = nil
    
    private var monthlyGoals: MonthlyGoals?
    private var monthlyTransactions: MonthlyTransactions?
    
    private var breakdowns: [BudgetBreakdown] = []
    private var transactions: [Transaction] = []
    
    // TITLE
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Balance", comment: "") + " :"
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        label.textColor = .white
        return label
    }()
    
    private let underLinePositionHeight: CGFloat = 56
    private let underLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // INCOME
    private var addBreakdownBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.6
        button.addTarget(self, action: #selector(addBreakdownTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private var incomTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.text = NSLocalizedString("Incom", comment: "")
        label.textColor = .white
        label.alpha = 0.6
        return label
    }()
    
    private var incomTableAriaHeightConstraint: NSLayoutConstraint?
    private let incomTableAria: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private var incomToolbarHeight: CGFloat = 48.0
    private lazy var incomToolbar: UIView = {
        let toolbar = UIView()
        toolbar.backgroundColor = .systemGray6
        toolbar.layer.shadowColor = UIColor.black.cgColor
        toolbar.layer.shadowOffset = CGSize(width: 0, height: 0)
        toolbar.layer.shadowOpacity = 0.2
        toolbar.layer.shadowRadius = 3
        toolbar.layer.masksToBounds = false
        return toolbar
    }()
    
    private let incomTotalLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.8
        label.textColor = .customDarkGray
        label.text = NSLocalizedString("Total", comment: "") + " :"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let incomTotalValue: UILabel = {
        let label = UILabel()
        label.alpha = 0.8
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let incomTableView: UITableView = {
        let tableView = UITableView()
        tableView.tag = 0
        tableView.register(BreakdownTableCell.self, forCellReuseIdentifier: BreakdownTableCell.identifier)
        return tableView
    }()
    
    // EXPENSE
    private var addTransactionBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.6
        button.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private var expenseTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.text = NSLocalizedString("Expenses", comment: "")
        label.textColor = .white
        label.alpha = 0.6
        return label
    }()
    
    private var expenseTableAriaHeightConstraint: NSLayoutConstraint?
    private let expenseTableAria: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private var expenseToolbarHeight: CGFloat = 48.0
    private lazy var expenseToolbar: UIView = {
        let toolbar = UIView()
        toolbar.backgroundColor = .systemGray6
        toolbar.layer.shadowColor = UIColor.black.cgColor
        toolbar.layer.shadowOffset = CGSize(width: 0, height: 0)
        toolbar.layer.shadowOpacity = 0.2
        toolbar.layer.shadowRadius = 3
        toolbar.layer.masksToBounds = false
        return toolbar
    }()
    
    private let expenseTotalLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.8
        label.textColor = .customDarkGray
        label.text = NSLocalizedString("Total", comment: "") + " :"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let expenseTotalValue: UILabel = {
        let label = UILabel()
        label.alpha = 0.8
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let expenseTableView: UITableView = {
        let tableView = UITableView()
        tableView.tag = 1
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.identifier)
        return tableView
    }()
    
    // INITIALIZE
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure(monthlyGoals: MonthlyGoals, monthlyTransactions: MonthlyTransactions) {
        self.monthlyGoals = monthlyGoals
        self.monthlyTransactions = monthlyTransactions
        
        self.updateViews()
    }
    
    private func updateViews() {
        if self.monthlyGoals != nil {
            self.breakdowns = self.monthlyGoals!.budgetBreakdowns
            
            let income = self.monthlyGoals!.getTotalBudget()
            incomTotalValue.text = "+ " + formatCurrency(amount: income)!
            expenseTableView.reloadData()
        }
        
        if self.monthlyTransactions != nil {
            self.transactions = self.monthlyTransactions!.transactions
            
            let expense = self.monthlyTransactions!.getExpense()
            expenseTotalValue.text = "- " + formatCurrency(amount: expense)!
            
            incomTableView.reloadData()
        }
        self.updateTableHeight()
    }
    
    private func setupUI() {
        self.addSubview(titleLabel)
        self.addSubview(underLine)
//        self.addSubview(incomTitleLabel)
//        self.addSubview(addBreakdownBtn)
//        self.addSubview(incomTableAria)
        self.addSubview(expenseTitleLabel)
        self.addSubview(addTransactionBtn)
        self.addSubview(expenseTableAria)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        underLine.translatesAutoresizingMaskIntoConstraints = false
        incomTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addBreakdownBtn.translatesAutoresizingMaskIntoConstraints = false
        incomTableAria.translatesAutoresizingMaskIntoConstraints = false
        expenseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addTransactionBtn.translatesAutoresizingMaskIntoConstraints = false
        expenseTableAria.translatesAutoresizingMaskIntoConstraints = false
        
        incomTableAriaHeightConstraint = incomTableAria.heightAnchor.constraint(equalToConstant: 0)
        expenseTableAriaHeightConstraint = expenseTableAria.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // TITLE
            titleLabel.bottomAnchor.constraint(equalTo: underLine.topAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: underLine.leadingAnchor, constant: 16),
            
            underLine.topAnchor.constraint(equalTo: self.topAnchor, constant: underLinePositionHeight),
            underLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            underLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            underLine.heightAnchor.constraint(equalToConstant: 1),
            
            // INCOME
            incomTitleLabel.topAnchor.constraint(equalTo: underLine.bottomAnchor, constant: 18),
            incomTitleLabel.trailingAnchor.constraint(equalTo: incomTableAria.trailingAnchor, constant: -16),
            
            addBreakdownBtn.centerYAnchor.constraint(equalTo: incomTitleLabel.centerYAnchor),
            addBreakdownBtn.leadingAnchor.constraint(equalTo: incomTableAria.leadingAnchor, constant: 16),
            addBreakdownBtn.widthAnchor.constraint(equalToConstant: 20),
            addBreakdownBtn.heightAnchor.constraint(equalToConstant: 20),
            
            incomTableAria.topAnchor.constraint(equalTo: incomTitleLabel.bottomAnchor, constant: 6),
            incomTableAria.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            incomTableAria.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            incomTableAriaHeightConstraint!,
            
            // EXPENSE
            expenseTitleLabel.topAnchor.constraint(equalTo: incomTableAria.bottomAnchor, constant: 18),
            expenseTitleLabel.trailingAnchor.constraint(equalTo: expenseTableAria.trailingAnchor, constant: -16),
            
            addTransactionBtn.centerYAnchor.constraint(equalTo: expenseTitleLabel.centerYAnchor),
            addTransactionBtn.leadingAnchor.constraint(equalTo: expenseTableAria.leadingAnchor, constant: 16),
            addTransactionBtn.widthAnchor.constraint(equalToConstant: 20),
            addTransactionBtn.heightAnchor.constraint(equalToConstant: 20),
            
            expenseTableAria.topAnchor.constraint(equalTo: expenseTitleLabel.bottomAnchor, constant: 6),
            expenseTableAria.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            expenseTableAria.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            expenseTableAriaHeightConstraint!
        ])
        
        // IncomTableAria
        incomTableAria.addSubview(incomToolbar)
        incomTableAria.addSubview(incomTableView)
        incomToolbar.addSubview(incomTotalLabel)
        incomToolbar.addSubview(incomTotalValue)
        
        incomTableView.delegate = self
        incomTableView.dataSource = self
        
        incomToolbar.translatesAutoresizingMaskIntoConstraints = false
        incomTableView.translatesAutoresizingMaskIntoConstraints = false
        incomTotalLabel.translatesAutoresizingMaskIntoConstraints = false
        incomTotalValue.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            incomToolbar.topAnchor.constraint(equalTo: incomTableAria.topAnchor),
            incomToolbar.leadingAnchor.constraint(equalTo: incomTableAria.leadingAnchor),
            incomToolbar.trailingAnchor.constraint(equalTo: incomTableAria.trailingAnchor),
            incomToolbar.heightAnchor.constraint(equalToConstant: incomToolbarHeight),
            
            incomTotalLabel.centerYAnchor.constraint(equalTo: incomToolbar.centerYAnchor),
            incomTotalLabel.leadingAnchor.constraint(equalTo: incomToolbar.leadingAnchor, constant: 32),
            
            incomTotalValue.centerYAnchor.constraint(equalTo: incomToolbar.centerYAnchor),
            incomTotalValue.trailingAnchor.constraint(equalTo: incomToolbar.trailingAnchor, constant: -16),
            
            incomTableView.topAnchor.constraint(equalTo: incomToolbar.bottomAnchor),
            incomTableView.leadingAnchor.constraint(equalTo: incomTableAria.leadingAnchor),
            incomTableView.trailingAnchor.constraint(equalTo: incomTableAria.trailingAnchor),
            incomTableView.bottomAnchor.constraint(equalTo: incomTableAria.bottomAnchor)
        ])
        
        // ExpenseTableAria
        expenseTableAria.addSubview(expenseToolbar)
        expenseTableAria.addSubview(expenseTableView)
        expenseToolbar.addSubview(expenseTotalLabel)
        expenseToolbar.addSubview(expenseTotalValue)
        
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        
        expenseToolbar.translatesAutoresizingMaskIntoConstraints = false
        expenseTableView.translatesAutoresizingMaskIntoConstraints = false
        expenseTotalLabel.translatesAutoresizingMaskIntoConstraints = false
        expenseTotalValue.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expenseToolbar.topAnchor.constraint(equalTo: expenseTableAria.topAnchor),
            expenseToolbar.leadingAnchor.constraint(equalTo: expenseTableAria.leadingAnchor),
            expenseToolbar.trailingAnchor.constraint(equalTo: expenseTableAria.trailingAnchor),
            expenseToolbar.heightAnchor.constraint(equalToConstant: expenseToolbarHeight),
            
            expenseTotalLabel.centerYAnchor.constraint(equalTo: expenseToolbar.centerYAnchor),
            expenseTotalLabel.leadingAnchor.constraint(equalTo: expenseToolbar.leadingAnchor, constant: 32),
            
            expenseTotalValue.centerYAnchor.constraint(equalTo: expenseToolbar.centerYAnchor),
            expenseTotalValue.trailingAnchor.constraint(equalTo: expenseToolbar.trailingAnchor, constant: -16),
            
            expenseTableView.topAnchor.constraint(equalTo: expenseToolbar.bottomAnchor),
            expenseTableView.leadingAnchor.constraint(equalTo: expenseTableAria.leadingAnchor),
            expenseTableView.trailingAnchor.constraint(equalTo: expenseTableAria.trailingAnchor),
            expenseTableView.bottomAnchor.constraint(equalTo: expenseTableAria.bottomAnchor)
        ])
    }
    
    private func updateTableHeight() {
        var incomTotalHeight: CGFloat = 0
        for section in 0..<incomTableView.numberOfSections {
            incomTotalHeight += incomTableView.rectForHeader(inSection: section).height
            for row in 0..<incomTableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                incomTotalHeight += incomTableView.rectForRow(at: indexPath).height
            }
        }
        incomTableAriaHeightConstraint?.constant = incomToolbarHeight + incomTotalHeight
    
        var expenseTotalHeight: CGFloat = 0
        for section in 0..<expenseTableView.numberOfSections {
            expenseTotalHeight += expenseTableView.rectForHeader(inSection: section).height
            for row in 0..<expenseTableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                expenseTotalHeight += expenseTableView.rectForRow(at: indexPath).height
            }
        }
        let expenseAriaHeight = expenseToolbarHeight + expenseTotalHeight
        expenseTableAriaHeightConstraint?.constant = expenseAriaHeight
        
        self.layoutIfNeeded()
        
        let contentHeight = max(UIScreen.main.bounds.height + 40, expenseTableAria.frame.maxY + 80)
        self.delegate!.updatedTotalDetailViewHeight(viewHeight: contentHeight)
    }
    
    // MARK: - Action
    @objc private func addBreakdownTapped() {
        self.delegate!.addBreakdownTapped()
    }
    
    @objc private func addTransactionTapped() {
        self.delegate!.addTransactionTapped()
    }
}

extension TotalDetailView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return breakdowns.count
        case 1:
            return transactions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:
            return BreakdownTableCell.cellHeight
        case 1:
            return TransactionTableViewCell.cellHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BreakdownTableCell.identifier, for: indexPath) as? BreakdownTableCell else {
                return UITableViewCell()
            }
            let breakdown = self.breakdowns[indexPath.row]
            cell.configure(with: breakdown)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as? TransactionTableViewCell else {
                return UITableViewCell()
            }
            let transaction = transactions[indexPath.row]
            cell.configure(with: transaction, categoryName: NSLocalizedString("Total", comment: ""))
            return cell
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.tag {
        case 0:
            self.delegate!.breakdownSelected(target: breakdowns[indexPath.row])
        case 1:
            self.delegate!.transactionSelected(target: transactions[indexPath.row])
        default:
            break
        }
    }
}
