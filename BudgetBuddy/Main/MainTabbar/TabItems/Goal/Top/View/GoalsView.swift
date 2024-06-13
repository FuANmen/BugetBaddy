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
        scrollView.backgroundColor = .clear
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
        view.backgroundColor = .clear
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
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 2
        view.layer.masksToBounds = false
        return view
    }()
    
    private let inExGoalsMinmumLineSpacing: CGFloat = 20
    private var inExGoalCollectionView: UICollectionView?
    
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
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure(targetMonth: String) {
        self.targetMonth = targetMonth
        self.inExGoals = GoalDao().getInExGoals(targetMonth: targetMonth)
        self.remainingGoal = GoalDao().getOtherGoal(targetMonth: targetMonth)
        inExGoalCollectionView!.reloadData()
        other.reloadData()
        updateTableViewHeight()
    }
    
    private func setupUI() {
        // InExCollectionView
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width*0.8, height: GoalItemCell.itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = self.inExGoalsMinmumLineSpacing

        inExGoalCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        inExGoalCollectionView!.backgroundColor = .clear
        inExGoalCollectionView!.dataSource = self
        inExGoalCollectionView!.delegate = self
        inExGoalCollectionView!.register(GoalItemCell.self, forCellWithReuseIdentifier: GoalItemCell.identifier)
        
        self.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(addGoalButton)
        scrollView.addSubview(underLine)
        scrollView.addSubview(mainShadowAria)
        scrollView.addSubview(mainAria)
        scrollView.addSubview(otherShadowAria)
        scrollView.addSubview(other)
        
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
        mainAria.addSubview(inExGoalCollectionView!)
        
        tableToolBar.translatesAutoresizingMaskIntoConstraints = false
        inExGoalCollectionView!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableToolBar.topAnchor.constraint(equalTo: mainAria.topAnchor),
            tableToolBar.heightAnchor.constraint(equalToConstant: toolbarHeight),
            tableToolBar.leadingAnchor.constraint(equalTo: mainAria.leadingAnchor),
            tableToolBar.trailingAnchor.constraint(equalTo: mainAria.trailingAnchor),
            
            inExGoalCollectionView!.topAnchor.constraint(equalTo: tableToolBar.bottomAnchor),
            inExGoalCollectionView!.leadingAnchor.constraint(equalTo: tableToolBar.leadingAnchor),
            inExGoalCollectionView!.trailingAnchor.constraint(equalTo: tableToolBar.trailingAnchor),
            inExGoalCollectionView!.bottomAnchor.constraint(equalTo: mainAria.bottomAnchor)
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
        for section in 0..<inExGoalCollectionView!.numberOfSections {
            for row in 0..<inExGoalCollectionView!.numberOfItems(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                totalHeight += GoalItemCell.itemHeight + inExGoalsMinmumLineSpacing
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
        case 1:
            let cell = self.other.dequeueReusableCell(withIdentifier: OtherGoalTableCell.identifier, for: indexPath) as! OtherGoalTableCell
            cell.configure(targetMonth: self.targetMonth)
            cell.backgroundColor = .customWhiteSmoke
            return cell
        default:
            let cell = self.other.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 1:
            return OtherGoalTableCell.cellHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.tag {
        case 1:
            self.delegate!.showGoalDetail(goal: self.remainingGoal!, imageColor: .systemTeal)
        default: break
        }
    }
}

extension GoalsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.inExGoals.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoalItemCell.identifier, for: indexPath) as! GoalItemCell
        cell.configure(with: inExGoals[indexPath.row], targetMonth: self.targetMonth)
        cell.contentView.backgroundColor = .customWhiteSmoke

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: inExGoalCollectionView!.layer.frame.width, height: GoalItemCell.itemHeight)
    }
}
