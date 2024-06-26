//
//  GoalsView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/22.
//

import UIKit

protocol GoalsViewDelegate: AnyObject {
    func addGoalButtonTapped()
    func showGoalDetail(goal: Goal)
    func updatedGoalsViewHeight(viewHeight: CGFloat)
}

class GoalsView: UIView {
    private var wallet: Wallet?
    private var monthlyGoals: MonthlyGoals?
    private var monthlyTransactions: MonthlyTransactions?
    
    weak var delegate: GoalsViewDelegate?
    
    private var inExGoals: [Goal] = []
    private var remainingGoal: Goal?
    
    // TITLE
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Categorized", comment: "") + " :"
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
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
    
    private let inExGoalsMinmumLineSpacing: CGFloat = 16
    private var inExGoalCollectionView: UICollectionView?
    
    // INITIALIZE
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure(wallet: Wallet,
                            monthlyGoals: MonthlyGoals,
                            monthlyTransactions: MonthlyTransactions) {
        self.wallet = wallet
        self.monthlyGoals = monthlyGoals
        self.monthlyTransactions = monthlyTransactions
        
        self.updateViews()
    }
    
    private func updateViews() {
        if self.monthlyGoals != nil {
            self.inExGoals = self.monthlyGoals!.goals
            inExGoalCollectionView!.reloadData()
            updateTableViewHeight()
        }
    }
    
    private func setupUI() {
        self.addSubview(titleLabel)
        self.addSubview(addGoalButton)
        self.addSubview(underLine)
        self.addSubview(mainShadowAria)
        self.addSubview(mainAria)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addGoalButton.translatesAutoresizingMaskIntoConstraints = false
        underLine.translatesAutoresizingMaskIntoConstraints = false
        mainAria.translatesAutoresizingMaskIntoConstraints = false
        mainShadowAria.translatesAutoresizingMaskIntoConstraints = false
        
        // 可変レイアウト
        mainAriaHeightConstraint = mainAria.heightAnchor.constraint(equalToConstant: toolbarHeight)
        
        NSLayoutConstraint.activate([
            // TITLE
            titleLabel.bottomAnchor.constraint(equalTo: underLine.topAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: underLine.leadingAnchor, constant: 16),
            
            addGoalButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addGoalButton.trailingAnchor.constraint(equalTo: underLine.trailingAnchor, constant: -32),
            addGoalButton.heightAnchor.constraint(equalToConstant: 20),
            addGoalButton.widthAnchor.constraint(equalToConstant: 20),
            
            underLine.topAnchor.constraint(equalTo: self.topAnchor, constant: underLinePositionHeight),
            underLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            underLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            underLine.heightAnchor.constraint(equalToConstant: 2),
            
            // MAIN
            mainAria.topAnchor.constraint(equalTo: underLine.bottomAnchor, constant: 24),
            mainAria.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainAria.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainAriaHeightConstraint!,
            
            mainShadowAria.topAnchor.constraint(equalTo: mainAria.topAnchor),
            mainShadowAria.leadingAnchor.constraint(equalTo: mainAria.leadingAnchor),
            mainShadowAria.trailingAnchor.constraint(equalTo: mainAria.trailingAnchor),
            mainShadowAria.bottomAnchor.constraint(equalTo: mainAria.bottomAnchor)
        ])
        
        // MainAria
        mainAria.addSubview(tableToolBar)
        setupGoalsCollectionView()
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
    
    private func setupGoalsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width*0.9, height: GoalItemCell.itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = self.inExGoalsMinmumLineSpacing

        inExGoalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        inExGoalCollectionView!.backgroundColor = .clear
        inExGoalCollectionView!.dataSource = self
        inExGoalCollectionView!.delegate = self
        inExGoalCollectionView!.register(GoalItemCell.self, forCellWithReuseIdentifier: GoalItemCell.identifier)
        inExGoalCollectionView!.isScrollEnabled = false
        inExGoalCollectionView!.layer.masksToBounds = false
        inExGoalCollectionView!.tag = 1
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
                totalHeight += GoalItemCell.itemHeight + inExGoalsMinmumLineSpacing
            }
        }
        mainAriaHeightConstraint?.constant = toolbarHeight + totalHeight
        
        self.layoutIfNeeded()
        
        let contentHeight = max(UIScreen.main.bounds.height + 40, inExGoalCollectionView!.frame.maxY + 80)
        
        self.delegate!.updatedGoalsViewHeight(viewHeight: contentHeight)
    }
}

// MARK: - CollectionViewDataSource, CollectionViewDelegate
extension GoalsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.inExGoals.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoalItemCell.identifier, for: indexPath) as! GoalItemCell
        cell.contentView.backgroundColor = .customWhiteSmoke
        
        let goal = self.inExGoals[indexPath.row]
        guard let category = self.wallet!.getCategoryById(categoryId: goal.categoryId) else {
            return cell
        }
        cell.configure(category: category,
                       goal: goal,
                       categoryOfExpense: self.monthlyTransactions!.getCategoryOfExpense(categoryId: goal.categoryId))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = inExGoalCollectionView?.cellForItem(at: indexPath) as! GoalItemCell
        self.delegate!.showGoalDetail(goal: self.inExGoals[indexPath.row])
    }
}
