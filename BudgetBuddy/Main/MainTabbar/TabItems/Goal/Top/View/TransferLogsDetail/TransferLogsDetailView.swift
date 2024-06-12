//
//  TransferLogsDetailView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/24.
//

import UIKit
import RealmSwift

class TransferLogsDetailView: UIView {
    private var targetMonth: String = ""
    private var goals: [Goal] = []
    private var otherGoal: Goal? = nil
    private var expandedSections: [Bool] = []
    
    // Scroll
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = BACKGROUND_COLOR
        return scrollView
    }()
    
    // TITLE
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "" // NSLocalizedString("Breakdown", comment: "") + " :"
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

    // UNCATEGORIZED
    private let uncategorizedViewHeight: CGFloat = 50
    private lazy var uncategorizedView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.systemGray.cgColor
        view.layer.cornerRadius = 18
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let uncategorizedLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("uncategorized", comment: "") + " :"
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        label.textColor = .systemGray2
        return label
    }()
    
    private let uncategorizedValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .systemGray2
        return label
    }()
    
    // CATEGORIZED
    private var categorizedAriaHeightAnchor: NSLayoutConstraint?
    private let categorizedAria: UIView = {
        let view = UIView()
        view.backgroundColor = BACKGROUND_COLOR
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let categorizedViewHeight: CGFloat = 50
    private lazy var categorizedView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.systemGray.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let categorizedLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("categorized", comment: "") + " :"
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        label.textColor = .systemGray2
        return label
    }()
    
    private let categorizedValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .systemGray2
        return label
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = BACKGROUND_COLOR
        tableView.register(TransferLogTableCell.self, forCellReuseIdentifier: TransferLogTableCell.identifier)
        return tableView
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure(targetMonth: String) {
        self.targetMonth = targetMonth
        self.goals = GoalDao().getInExGoals(targetMonth: targetMonth)
        self.otherGoal = GoalDao().getOtherGoal(targetMonth: targetMonth)
        
        expandedSections = []
        for i in 0..<goals.count {
            expandedSections.append(false)
        }
        
        var total: Double = 0
        self.goals.forEach { goal in
            total += goal.getAmount()
        }
        
        uncategorizedValue.text = formatCurrency(amount: otherGoal!.getAmount())
        categorizedValue.text = formatCurrency(amount: total)
        tableView.reloadData()
        self.updateTableViewHeight()
    }
    
    internal func scrollToTop() {
        self.scrollView.scrollRectToVisible(.init(x: scrollView.contentOffset.x
                                                  , y: 0
                                                  , width: scrollView.frame.width
                                                  , height: scrollView.frame.height)
                                            , animated: true)
    }
    
    private func setupUI() {
        self.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(underLine)
        scrollView.addSubview(uncategorizedView)
        scrollView.addSubview(categorizedAria)
        categorizedAria.addSubview(categorizedView)
        categorizedAria.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        underLine.translatesAutoresizingMaskIntoConstraints = false
        uncategorizedView.translatesAutoresizingMaskIntoConstraints = false
        categorizedAria.translatesAutoresizingMaskIntoConstraints = false
        categorizedView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        categorizedAriaHeightAnchor = categorizedAria.heightAnchor.constraint(equalToConstant: categorizedViewHeight)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: underLine.topAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: underLine.leadingAnchor, constant: 16),
            
            underLine.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: underLinePositionHeight),
            underLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            underLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            underLine.heightAnchor.constraint(equalToConstant: 1),
            
            uncategorizedView.topAnchor.constraint(equalTo: underLine.bottomAnchor, constant: 24),
            uncategorizedView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            uncategorizedView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            uncategorizedView.heightAnchor.constraint(equalToConstant: uncategorizedViewHeight),
            
            categorizedAria.topAnchor.constraint(equalTo: uncategorizedView.bottomAnchor, constant: 32),
            categorizedAria.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            categorizedAria.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            categorizedAriaHeightAnchor!,
            
            categorizedView.topAnchor.constraint(equalTo: categorizedAria.topAnchor),
            categorizedView.leadingAnchor.constraint(equalTo: categorizedAria.leadingAnchor),
            categorizedView.trailingAnchor.constraint(equalTo: categorizedAria.trailingAnchor),
            categorizedView.heightAnchor.constraint(equalToConstant: categorizedViewHeight),
            
            tableView.topAnchor.constraint(equalTo: categorizedView.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: categorizedAria.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: categorizedAria.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: categorizedAria.bottomAnchor)
        ])
        
        // Uncategorized
        uncategorizedView.addSubview(uncategorizedLabel)
        uncategorizedView.addSubview(uncategorizedValue)
        
        uncategorizedLabel.translatesAutoresizingMaskIntoConstraints = false
        uncategorizedValue.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            uncategorizedLabel.centerYAnchor.constraint(equalTo: uncategorizedView.centerYAnchor),
            uncategorizedLabel.leadingAnchor.constraint(equalTo: uncategorizedView.leadingAnchor, constant: 24),
            
            uncategorizedValue.centerYAnchor.constraint(equalTo: uncategorizedView.centerYAnchor),
            uncategorizedValue.trailingAnchor.constraint(equalTo: uncategorizedView.trailingAnchor, constant: -18)
        ])
        
        // Categorized
        categorizedView.addSubview(categorizedLabel)
        categorizedView.addSubview(categorizedValue)
        
        categorizedLabel.translatesAutoresizingMaskIntoConstraints = false
        categorizedValue.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categorizedLabel.centerYAnchor.constraint(equalTo: categorizedView.centerYAnchor),
            categorizedLabel.leadingAnchor.constraint(equalTo: categorizedView.leadingAnchor, constant: 24),
            
            categorizedValue.centerYAnchor.constraint(equalTo: categorizedView.centerYAnchor),
            categorizedValue.trailingAnchor.constraint(equalTo: categorizedView.trailingAnchor, constant: -18)
        ])
    }
    
    private func updateTableViewHeight() {
        var totalHeight: CGFloat = 0
        for section in 0..<tableView.numberOfSections {
            totalHeight += tableView.rectForHeader(inSection: section).height * 2
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                totalHeight += tableView.rectForRow(at: indexPath).height
            }
        }
        
        categorizedAriaHeightAnchor?.constant = categorizedViewHeight + totalHeight + 12
        self.layoutIfNeeded()
        
        let contentHeight = max(self.frame.height + 100, categorizedAria.frame.maxY + 100)
        scrollView.contentSize = CGSize(width: self.frame.width, height: contentHeight)
    }
}

extension TransferLogsDetailView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TransferLogsTableSectionHeader()
        headerView.configure(goal: self.goals[section], sectionNum: section, expanded: expandedSections[section])
        headerView.delegate = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TransferLogsTableSectionHeader.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections[section] ? goals[section].transLogsAsDest.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: TransferLogTableCell.identifier, for: indexPath) as! TransferLogTableCell
        cell.configure(transferLog: goals[indexPath.section].transLogsAsDest[indexPath.row])
        return cell
    }
}

extension TransferLogsDetailView: TransferLogsTableSectionHeaderDelegate {
    internal func openAndCloseCellBtnTapped(sectionNum: Int) {
        expandedSections[sectionNum].toggle()
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: sectionNum), with: .fade)
        tableView.endUpdates()
        
        self.updateTableViewHeight()
    }
}

extension TransferLogsDetailView: CreateTransferLogViewDelegate {
    func didAddTransferLog() {
        tableView.reloadData()
        self.updateTableViewHeight()
    }
}
