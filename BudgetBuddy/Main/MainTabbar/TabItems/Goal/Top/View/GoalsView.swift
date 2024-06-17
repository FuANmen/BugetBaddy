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
    
    private let inExGoalsMinmumLineSpacing: CGFloat = 16
    private var inExGoalCollectionView: UICollectionView?
    
    // TotalGoal
    private var otherAriaHeightConstraint: NSLayoutConstraint?
    private var otherGoalCollectionView: UICollectionView?
    
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
        otherGoalCollectionView!.reloadData()
        updateTableViewHeight()
    }
    
    private func setupUI() {
        
        self.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(addGoalButton)
        scrollView.addSubview(underLine)
        scrollView.addSubview(mainShadowAria)
        scrollView.addSubview(mainAria)
        
        setupOtherGoalCollectionView()
        scrollView.addSubview(otherGoalCollectionView!)
        
        otherGoalCollectionView!.delegate = self
        otherGoalCollectionView!.dataSource = self
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addGoalButton.translatesAutoresizingMaskIntoConstraints = false
        underLine.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mainAria.translatesAutoresizingMaskIntoConstraints = false
        mainShadowAria.translatesAutoresizingMaskIntoConstraints = false
        otherGoalCollectionView!.translatesAutoresizingMaskIntoConstraints = false
        
        // 可変レイアウト
        mainAriaHeightConstraint = mainAria.heightAnchor.constraint(equalToConstant: toolbarHeight)
        otherAriaHeightConstraint = otherGoalCollectionView!.heightAnchor.constraint(equalToConstant: 0)
        
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
            otherGoalCollectionView!.topAnchor.constraint(equalTo: mainAria.bottomAnchor, constant: 28),
            otherGoalCollectionView!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 28),
            otherGoalCollectionView!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -28),
            otherAriaHeightConstraint!
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
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width*0.8, height: GoalItemCell.itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = self.inExGoalsMinmumLineSpacing

        inExGoalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        inExGoalCollectionView!.backgroundColor = .clear
        inExGoalCollectionView!.dataSource = self
        inExGoalCollectionView!.delegate = self
        inExGoalCollectionView!.register(GoalItemCell.self, forCellWithReuseIdentifier: GoalItemCell.identifier)
        inExGoalCollectionView!.isScrollEnabled = false
        inExGoalCollectionView!.tag = 1
    }
    
    private func setupOtherGoalCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: OtherGoalItemCell.itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        
        otherGoalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        otherGoalCollectionView!.backgroundColor = .clear
        otherGoalCollectionView!.dataSource = self
        otherGoalCollectionView!.delegate = self
        otherGoalCollectionView!.register(OtherGoalItemCell.self, forCellWithReuseIdentifier: OtherGoalItemCell.identifier)
        otherGoalCollectionView!.isScrollEnabled = false
        otherGoalCollectionView!.tag = 2 // Unique tag for identification
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
        for row in 0..<otherGoalCollectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            otherTotalHeight += OtherGoalItemCell.itemHeight
        }
        otherAriaHeightConstraint?.constant = otherTotalHeight
        
        self.layoutIfNeeded()
        
        let contentHeight = max(self.frame.height + 100, otherGoalCollectionView!.frame.maxY + otherTotalHeight + 100)
        scrollView.contentSize = CGSize(width: self.frame.width, height: contentHeight)
    }
}

// MARK: - CollectionViewDataSource, CollectionViewDelegate
extension GoalsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return inExGoals.count
        case 2:
            return remainingGoal?.getAmount() ?? 0 > 0 ? 1 : 0
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoalItemCell.identifier, for: indexPath) as! GoalItemCell
            cell.configure(with: inExGoals[indexPath.row], targetMonth: self.targetMonth)
            cell.contentView.backgroundColor = .customWhiteSmoke
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherGoalItemCell.identifier, for: indexPath) as! OtherGoalItemCell
            cell.configure(targetMonth: self.targetMonth)
            cell.contentView.backgroundColor = .customWhiteSmoke
            return cell
        default:
            fatalError("Unknown collection view tag")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch collectionView.tag {
        case 1:
            let cell = inExGoalCollectionView?.cellForItem(at: indexPath) as! GoalItemCell
            self.delegate!.showGoalDetail(goal: self.inExGoals[indexPath.row], imageColor: cell.imageColor)
        case 2:
            self.delegate!.showGoalDetail(goal: self.remainingGoal!, imageColor: .systemTeal)
        default: break
        }
    }
}
