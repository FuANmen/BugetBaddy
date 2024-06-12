//
//  GoalsView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/22.
//

import UIKit

protocol GoalsViewDelegate: AnyObject {
    func addGoalButtonTapped()
    func showGoalDetail(goal: Goal, imageColor: UIColor)
}

class GoalsView: UIView {
    private var targetMonth: String = ""
    
    weak var delegate: GoalsViewDelegate?
    
    private var inExGoals: [Goal] = []
    private var remainingGoal: Goal?
     
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
        label.text = NSLocalizedString("Categorized", comment: "") + " :"
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        label.textColor = .white
        return label
    }()
    
    private let addGoalButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(addGoalButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let underLinePositionHeight: CGFloat = 56
    private let underLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // InExGoals
    private var mainAriaHeightConstraint: NSLayoutConstraint?
    private let mainAria: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    private let mainShadowAria: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.shadowOffset = CGSize(width: 1, height: -1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let toolbarHeight: CGFloat = 0
    private let tableToolBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 2
        view.layer.masksToBounds = false
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tag = 0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(GoalTableViewCell.self, forCellReuseIdentifier: GoalTableViewCell.identifier)
        tableView.tableFooterView = UIView() // 空のセルの区切り線を削除
        return tableView
    }()
    
    // TotalGoal
    private var otherAriaHeightConstraint: NSLayoutConstraint?
    private let other: UITableView = {
        let tableView = UITableView()
        tableView.tag = 1
        tableView.register(OtherGoalTableCell.self, forCellReuseIdentifier: OtherGoalTableCell.identifier)
        tableView.tableFooterView = UIView() // 空のセルの区切り線を削除
        tableView.layer.cornerRadius = 18
        tableView.layer.masksToBounds = true
        return tableView
    }()
    private let otherShadowAria: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        return view
    }()
    
    // INITIALIZE
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure(targetMonth: String) {
        self.targetMonth = targetMonth
        self.inExGoals = GoalDao().getInExGoals(targetMonth: targetMonth)
        self.remainingGoal = GoalDao().getOtherGoal(targetMonth: targetMonth)
        tableView.reloadData()
        other.reloadData()
        updateTableViewHeight()
    }
    
    private func setupUI() {
        self.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(addGoalButton)
        scrollView.addSubview(underLine)
        scrollView.addSubview(mainShadowAria)
        scrollView.addSubview(mainAria)
        scrollView.addSubview(otherShadowAria)
        scrollView.addSubview(other)
        
        tableView.delegate = self
        tableView.dataSource = self
        other.delegate = self
        other.dataSource = self
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addGoalButton.translatesAutoresizingMaskIntoConstraints = false
        underLine.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mainAria.translatesAutoresizingMaskIntoConstraints = false
        mainShadowAria.translatesAutoresizingMaskIntoConstraints = false
        other.translatesAutoresizingMaskIntoConstraints = false
        otherShadowAria.translatesAutoresizingMaskIntoConstraints = false
        
        // 可変レイアウト
        mainAriaHeightConstraint = mainAria.heightAnchor.constraint(equalToConstant: toolbarHeight)
        otherAriaHeightConstraint = other.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // TITLE
            titleLabel.bottomAnchor.constraint(equalTo: underLine.topAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: underLine.leadingAnchor, constant: 16),
            
            addGoalButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addGoalButton.trailingAnchor.constraint(equalTo: underLine.trailingAnchor, constant: -32),
            addGoalButton.heightAnchor.constraint(equalToConstant: 20),
            addGoalButton.widthAnchor.constraint(equalToConstant: 20),
            
            underLine.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: underLinePositionHeight),
            underLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            underLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            underLine.heightAnchor.constraint(equalToConstant: 1),
            
            // MAIN
            mainAria.topAnchor.constraint(equalTo: underLine.bottomAnchor, constant: 24),
            mainAria.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 28),
            mainAria.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -28),
            mainAriaHeightConstraint!,
            
            mainShadowAria.topAnchor.constraint(equalTo: mainAria.topAnchor),
            mainShadowAria.leadingAnchor.constraint(equalTo: mainAria.leadingAnchor),
            mainShadowAria.trailingAnchor.constraint(equalTo: mainAria.trailingAnchor),
            mainShadowAria.bottomAnchor.constraint(equalTo: mainAria.bottomAnchor),
            
            // TOTAL
            other.topAnchor.constraint(equalTo: mainAria.bottomAnchor, constant: 28),
            other.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 28),
            other.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -28),
            otherAriaHeightConstraint!,
            
            otherShadowAria.topAnchor.constraint(equalTo: other.topAnchor),
            otherShadowAria.leadingAnchor.constraint(equalTo: other.leadingAnchor),
            otherShadowAria.trailingAnchor.constraint(equalTo: other.trailingAnchor),
            otherShadowAria.bottomAnchor.constraint(equalTo: other.bottomAnchor),
        ])
        
        // MainAria
        mainAria.addSubview(tableToolBar)
        mainAria.addSubview(tableView)
        
        tableToolBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableToolBar.topAnchor.constraint(equalTo: mainAria.topAnchor),
            tableToolBar.heightAnchor.constraint(equalToConstant: toolbarHeight),
            tableToolBar.leadingAnchor.constraint(equalTo: mainAria.leadingAnchor),
            tableToolBar.trailingAnchor.constraint(equalTo: mainAria.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: tableToolBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableToolBar.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableToolBar.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: mainAria.bottomAnchor)
        ])
    }
    
    internal func scrollToTop() {
        self.scrollView.scrollRectToVisible(.init(x: scrollView.contentOffset.x
                                                  , y: 0
                                                  , width: scrollView.frame.width
                                                  , height: scrollView.frame.height)
                                            , animated: true)
    }
    
    // MARK: - ACTIONS
    @objc private func addGoalButtonTapped() {
        self.delegate!.addGoalButtonTapped()
    }
    
    // MARK: - EVENTS
    private func updateTableViewHeight() {
        var totalHeight: CGFloat = 0
        for section in 0..<tableView.numberOfSections {
            totalHeight += tableView.rectForHeader(inSection: section).height
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                totalHeight += tableView.rectForRow(at: indexPath).height
            }
        }
        mainAriaHeightConstraint?.constant = toolbarHeight + totalHeight
        
        var otherTotalHeight: CGFloat = 0
        for row in 0..<other.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            otherTotalHeight += other.rectForRow(at: indexPath).height
        }
        otherAriaHeightConstraint?.constant = otherTotalHeight
        
        self.layoutIfNeeded()
        
        let contentHeight = max(self.frame.height + 100, other.frame.maxY + otherTotalHeight + 100)
        scrollView.contentSize = CGSize(width: self.frame.width, height: contentHeight)
    }
}

// MARK: - TableViewDataSource, TableViewDelegate
extension GoalsView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return inExGoals.count
        case 1:
            return remainingGoal!.getAmount() > 0 ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let goal = inExGoals[indexPath.row]
            if goal.createdByUser_flg {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: GoalTableViewCell.identifier, for: indexPath) as! GoalTableViewCell
                cell.configure(with: goal, targetMonth: self.targetMonth)
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        case 1:
            let cell = self.other.dequeueReusableCell(withIdentifier: OtherGoalTableCell.identifier, for: indexPath) as! OtherGoalTableCell
            cell.configure(targetMonth: self.targetMonth)
            return cell
        default:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:
            return GoalTableViewCell.cellHeight
        case 1:
            return OtherGoalTableCell.cellHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.tag {
        case 0:
            let cell = tableView.cellForRow(at: indexPath) as! GoalTableViewCell
            self.delegate!.showGoalDetail(goal: inExGoals[indexPath.row], imageColor: cell.imageColor)
        case 1:
            self.delegate!.showGoalDetail(goal: self.remainingGoal!, imageColor: .systemTeal)
        default: break
        }
    }
}
